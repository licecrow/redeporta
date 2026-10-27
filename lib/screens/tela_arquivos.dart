import 'package:flutter/material.dart';

import '../models/dispositivo.dart';

class ItemArquivo {
  final String nome;
  final bool pasta;
  final String tamanho;
  final String data;
  const ItemArquivo(this.nome, this.pasta, this.tamanho, this.data);
}

const Map<String, List<ItemArquivo>> _arvore = <String, List<ItemArquivo>>{
  'raiz': <ItemArquivo>[
    ItemArquivo('Fotos', true, '', ''),
    ItemArquivo('Documentos', true, '', ''),
    ItemArquivo('Downloads', true, '', ''),
    ItemArquivo('relatorio_final.pdf', false, '2,4 MB', '12 Out'),
    ItemArquivo('video_treino.mp4', false, '180 MB', '10 Out'),
    ItemArquivo('planilha_custos.xlsx', false, '640 KB', '08 Out'),
  ],
  'Fotos': <ItemArquivo>[
    ItemArquivo('foto_familia.jpg', false, '3,1 MB', '02 Out'),
    ItemArquivo('praia.png', false, '1,8 MB', '28 Set'),
  ],
  'Documentos': <ItemArquivo>[
    ItemArquivo('contrato.pdf', false, '880 KB', '20 Out'),
    ItemArquivo('notas.txt', false, '4 KB', '15 Out'),
  ],
  'Downloads': <ItemArquivo>[
    ItemArquivo('instalador.apk', false, '45 MB', '11 Out'),
  ],
};

class TelaArquivos extends StatefulWidget {
  final Dispositivo? dispositivo;
  const TelaArquivos({super.key, required this.dispositivo});

  @override
  State<TelaArquivos> createState() => _TelaArquivosState();
}

class _TelaArquivosState extends State<TelaArquivos> {
  String _pasta = 'raiz';

  IconData _icone(ItemArquivo a) {
    if (a.pasta) return Icons.folder;
    if (a.nome.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (a.nome.endsWith('.mp4')) return Icons.movie;
    if (a.nome.endsWith('.jpg') || a.nome.endsWith('.png')) return Icons.image;
    if (a.nome.endsWith('.xlsx')) return Icons.table_chart;
    if (a.nome.endsWith('.apk')) return Icons.android;
    return Icons.insert_drive_file;
  }

  void _ver(ItemArquivo a) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(a.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icone(a), size: 72),
            const SizedBox(height: 12),
            Text('${a.tamanho}  ·  ${a.data}'),
            const SizedBox(height: 8),
            const Text('Visualizacao em streaming pela porta.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _salvar(ItemArquivo a) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Salvo em /Download/${a.nome}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dispositivo == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum dispositivo conectado.\n'
            'Va na aba Portas e toque em Conectar.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final d = widget.dispositivo!;
    final itens = _arvore[_pasta] ?? const <ItemArquivo>[];

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
                    if (_pasta != 'raiz')
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => _pasta = 'raiz'),
                      ),
                    Expanded(
                      child: Text(
                        d.nome,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Chip(
                      label: Text('Conectado'),
                      backgroundColor: Colors.green,
                    ),
                  ],
                ),
                Text(
                  _pasta == 'raiz' ? 'Inicio' : 'Inicio / $_pasta',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, i) {
                final a = itens[i];
                return ListTile(
                  leading: Icon(
                    _icone(a),
                    color: a.pasta ? Colors.amber : null,
                  ),
                  title: Text(a.nome),
                  subtitle: a.pasta ? null : Text('${a.tamanho}  ·  ${a.data}'),
                  onTap: a.pasta ? () => setState(() => _pasta = a.nome) : null,
                  trailing: a.pasta
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _ver(a),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _salvar(a),
                            ),
                          ],
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
