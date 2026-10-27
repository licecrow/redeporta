import 'package:flutter/material.dart';

import 'models/dispositivo.dart';
import 'screens/tela_arquivos.dart';
import 'screens/tela_portas.dart';
import 'screens/tela_rede.dart';
import 'services/servico_porta.dart';

void main() => runApp(const AppRedePorta());

class AppRedePorta extends StatefulWidget {
  const AppRedePorta({super.key});

  @override
  State<AppRedePorta> createState() => _AppRedePortaState();
}

class _AppRedePortaState extends State<AppRedePorta> {
  final ServicoPorta servico = ServicoPorta();
  int aba = 0;
  Dispositivo? conectado;

  void abrirArquivos(Dispositivo d) {
    setState(() {
      conectado = d;
      aba = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final telas = <Widget>[
      TelaRede(servico: servico),
      TelaPortas(servico: servico, aoConectar: abrirArquivos),
      TelaArquivos(dispositivo: conectado),
    ];

    return MaterialApp(
      title: 'RedePorta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      home: Scaffold(
        body: telas[aba],
        bottomNavigationBar: NavigationBar(
          selectedIndex: aba,
          onDestinationSelected: (i) => setState(() => aba = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.wifi), label: 'Rede'),
            NavigationDestination(icon: Icon(Icons.vpn_key), label: 'Portas'),
            NavigationDestination(icon: Icon(Icons.folder), label: 'Arquivos'),
          ],
        ),
      ),
    );
  }
}
