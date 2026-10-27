import 'dart:async';
import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

import '../models/dispositivo.dart';

class VarreduraRede {
  static const List<int> portasComuns = <int>[80, 443, 445, 22, 8080, 5000, 62078];

  Future<String> nomeDaRede() async {
    try {
      final ssid = await NetworkInfo().getWifiName();
      if (ssid != null && ssid.isNotEmpty) return ssid.replaceAll('"', '');
    } catch (_) {}
    return 'Rede local';
  }

  Future<String?> ipLocal() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final i in interfaces) {
        for (final a in i.addresses) {
          if (a.address.startsWith('192.168.') ||
              a.address.startsWith('10.') ||
              a.address.startsWith('172.')) {
            return a.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<List<Dispositivo>> varrer({
    void Function(int feitos, int total)? progresso,
  }) async {
    final meuIp = await ipLocal();
    if (meuIp == null) return <Dispositivo>[];

    final partes = meuIp.split('.');
    final prefixo = '${partes[0]}.${partes[1]}.${partes[2]}.';
    final alvos = List<String>.generate(254, (i) => '$prefixo${i + 1}');

    final achados = <Dispositivo>[];
    var feitos = 0;

    for (var inicio = 0; inicio < alvos.length; inicio += 32) {
      final fim = (inicio + 32) > alvos.length ? alvos.length : inicio + 32;
      final lote = alvos.sublist(inicio, fim);
      final resultados = await Future.wait(lote.map(_testar));
      for (final d in resultados) {
        if (d != null) achados.add(d);
      }
      feitos += lote.length;
      progresso?.call(feitos, alvos.length);
    }
    return achados;
  }

  Future<Dispositivo?> _testar(String ip) async {
    final abertas = <int>[];
    final cronometro = Stopwatch()..start();

    for (final porta in portasComuns) {
      try {
        final s = await Socket.connect(
          ip,
          porta,
          timeout: const Duration(milliseconds: 250),
        );
        s.destroy();
        abertas.add(porta);
      } catch (_) {}
    }
    cronometro.stop();

    if (abertas.isEmpty) return null;

    var nome = ip;
    try {
      final rev = await InternetAddress(ip)
          .reverse()
          .timeout(const Duration(milliseconds: 500));
      if (rev.host.isNotEmpty && rev.host != ip) nome = rev.host;
    } catch (_) {}

    return Dispositivo(
      ip: ip,
      nome: nome,
      so: _soPorPortas(abertas),
      portasAbertas: abertas,
      latenciaMs: cronometro.elapsedMilliseconds,
    );
  }

  String _soPorPortas(List<int> portas) {
    if (portas.contains(445)) return 'Windows';
    if (portas.contains(62078)) return 'iOS';
    if (portas.contains(22)) return 'Linux / macOS';
    if (portas.contains(80) || portas.contains(443)) return 'Roteador / IoT';
    return 'Desconhecido';
  }
}
