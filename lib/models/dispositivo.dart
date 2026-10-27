class Dispositivo {
  final String ip;
  final String nome;
  final String so;
  final List<int> portasAbertas;
  bool temPorta;
  bool online;
  int? latenciaMs;

  Dispositivo({
    required this.ip,
    required this.nome,
    required this.so,
    this.portasAbertas = const <int>[],
    this.temPorta = false,
    this.online = true,
    this.latenciaMs,
  });

  String get marca {
    final n = nome.toLowerCase();
    if (n.contains('poco') || n.contains('redmi') || n.contains('xiaomi')) {
      return 'Xiaomi';
    }
    if (n.contains('samsung') || n.contains('galaxy')) return 'Samsung';
    if (n.contains('iphone') || n.contains('ipad') || n.contains('apple')) {
      return 'Apple';
    }
    if (n.contains('dell')) return 'Dell';
    if (n.contains('lenovo')) return 'Lenovo';
    if (n.contains('lg')) return 'LG';
    if (n.contains('hp')) return 'HP';
    if (n.contains('motorola') || n.contains('moto')) return 'Motorola';
    return 'Generico';
  }

  String get descricao {
    final partes = <String>[ip, so];
    if (latenciaMs != null) partes.add('${latenciaMs}ms');
    return partes.join('  ·  ');
  }
}
