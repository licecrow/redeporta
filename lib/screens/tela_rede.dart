import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/dispositivo.dart';
import '../services/servico_porta.dart';
import '../services/varredura_rede.dart';

class TelaRede extends StatefulWidget {
  final ServicoPorta servico;
  const TelaRede({super.key, required this.servico});

  @override
  State<TelaRede> createState() => _TelaRedeState();
}

class _TelaRedeState extends State<TelaRede> {
  final VarreduraRede _varredura = VarreduraRede();
  String _rede = 'Detectando...';
  List<Dispositivo> _dispositivos = <Dispositivo>[];
  bool _varrendo = false;
  int _progresso = 0;

  @override
  void initState() {
    super.initState();
    _atualizarRede();
  }

  Future<void> _atualizarRede() async {
    final nome = await _varredura.nomeDaRede();
    if (mounted) setState(() => _rede = nome);
  }

  Future<void> _varrer() async {
    await Permission.location.request();
    setState(() {
      _varrendo = true;
      _progresso = 0;
      _dispositivos = <Dispositivo>[];
    });

    final lista = await _varredura.varrer(progresso: (feitos, total) {
      if (mounted) {
        setState(() => _progresso =
            total == 0 ? 0 : ((feitos / total) * 100).round());
      }
    });

    lista.sort((a, b) => a.ip.compareTo(b.ip));
    if (!mounted) return;
    setState(() {
      _dispositivos = lista;
      _varrendo = false;
    });
    await _atualizarRede();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wifi),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Wi-Fi: $_rede',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_dispositivos.length} dispositivos na rede',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _varrendo ? null : _varrer,
                    icon: const Icon(Icons.search),
                    label: Text(_varrendo
                        ? 'Varrendo... $_progresso%'
                        : 'Varrer a rede'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _dispositivos.isEmpty
                ? Center(
                    child: Text(_varrendo
                        ? 'Procurando dispositivos...'
                        : 'Toque em "Varrer a rede"'),
                  )
                : ListView.builder(
                    itemCount: _dispositivos.length,
                    itemBuilder: (context, i) => _cartao(_dispositivos[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cartao(Dispositivo d) {
    final temPorta = widget.servico.temPorta(d.ip);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.devices),
        title: Text(
          '${d.marca}  ${d.nome}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${d.descricao}\nPortas: ${d.portasAbertas.join(", ")}'),
        isThreeLine: true,
        trailing: temPorta
            ? const Chip(label: Text('Porta ok'))
            : FilledButton(
                onPressed: () {
                  setState(() => widget.servico.instalar(d));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Porta instalada em ${d.nome}')),
                  );
                },
                child: const Text('Instalar'),
              ),
      ),
    );
  }
}
