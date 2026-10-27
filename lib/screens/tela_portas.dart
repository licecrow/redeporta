import 'package:flutter/material.dart';

import '../models/dispositivo.dart';
import '../services/servico_porta.dart';

class TelaPortas extends StatefulWidget {
  final ServicoPorta servico;
  final void Function(Dispositivo) aoConectar;

  const TelaPortas({
    super.key,
    required this.servico,
    required this.aoConectar,
  });

  @override
  State<TelaPortas> createState() => _TelaPortasState();
}

class _TelaPortasState extends State<TelaPortas> {
  Future<void> _conectar(Dispositivo d) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Negociando sessao com ${d.nome}...')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    widget.aoConectar(d);
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.servico.listar();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.vpn_key),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dispositivos com Porta',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nenhum dispositivo tem porta ainda.\n'
                        'Va na aba Rede e toque em Instalar.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final d = lista[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            Icons.circle,
                            size: 12,
                            color: d.online ? Colors.green : Colors.grey,
                          ),
                          title: Text(d.nome),
                          subtitle: Text(
                            '${d.so}  ·  Porta ${7800 + i}  ·  '
                            '${d.online ? "${d.latenciaMs ?? 0} ms" : "offline"}',
                          ),
                          trailing: FilledButton(
                            onPressed: d.online ? () => _conectar(d) : null,
                            child: const Text('Conectar'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
