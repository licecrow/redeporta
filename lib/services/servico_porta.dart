import '../models/dispositivo.dart';

class ServicoPorta {
  final Map<String, Dispositivo> _comPorta = <String, Dispositivo>{};

  bool temPorta(String ip) => _comPorta.containsKey(ip);

  Dispositivo instalar(Dispositivo d) {
    d.temPorta = true;
    _comPorta[d.ip] = d;
    return d;
  }

  List<Dispositivo> listar() => _comPorta.values.toList();

  void remover(String ip) => _comPorta.remove(ip);
}
