import 'pecas.dart';

class Loja {
  final String nome;
  final String Function(String termo) url;

  const Loja(this.nome, this.url);
}

final lojas = <Loja>[
  Loja(
    'Kabum',
    (t) => 'https://www.kabum.com.br/busca/${Uri.encodeComponent(t)}',
  ),
  Loja(
    'Pichau',
    (t) => 'https://www.pichau.com.br/search?q=${Uri.encodeComponent(t)}',
  ),
  Loja(
    'Terabyte',
    (t) =>
        'https://www.terabyteshop.com.br/busca?str=${Uri.encodeComponent(t)}',
  ),
  Loja(
    'Mercado Livre',
    (t) =>
        'https://lista.mercadolivre.com.br/${Uri.encodeComponent(t.replaceAll(RegExp(r'\s+'), '-'))}',
  ),
];

const prefixo = {
  'cpu': 'processador',
  'placa': 'placa mãe',
  'ram': 'memória ram',
  'gpu': 'placa de vídeo',
  'fonte': 'fonte',
  'gabinete': 'gabinete',
};

String termoBusca(String cat, Peca p) => '${prefixo[cat]} ${p.nome}';

String gerarTexto(Map<String, Peca> escolhidas) {
  final linhas = <String>['Minha montagem de PC (Bancada PC):', ''];
  for (final cat in categorias) {
    final p = escolhidas[cat.chave];
    if (p == null) continue;
    linhas.add('${cat.titulo}: ${p.nome}');
    for (final loja in lojas) {
      linhas.add('${loja.nome}: ${loja.url(termoBusca(cat.chave, p))}');
    }
    linhas.add('');
  }
  return linhas.join('\n');
}
