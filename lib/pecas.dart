class Peca {
  final String id;
  final String nome;
  final int preco;
  final String? soquete;
  final String? memoria;
  final int? watts;
  final int? gb;
  final int? comprimento;
  final int? maxGpu;
  final int? nota;
  final bool rec;
  final String? dica;

  const Peca(
    this.id,
    this.nome,
    this.preco, {
    this.soquete,
    this.memoria,
    this.watts,
    this.gb,
    this.comprimento,
    this.maxGpu,
    this.nota,
    this.rec = false,
    this.dica,
  });
}

class Categoria {
  final String chave;
  final String titulo;
  final List<Peca> itens;

  const Categoria(this.chave, this.titulo, this.itens);
}

class Montagem {
  final String nome;
  final String descricao;
  final Map<String, String> ids;

  const Montagem(this.nome, this.descricao, this.ids);
}

String dinheiro(int n) {
  final s = n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
  return 'R\$ $s,00';
}

String perfilDe(Peca p) {
  final n = p.nota;
  if (n == null) return '';
  if (n < 8) return 'Uso muito básico';
  if (n < 20) return 'Uso básico';
  if (n < 35) return 'Jogos leves';
  if (n < 50) return 'Jogos em Full HD';
  if (n < 70) return 'Jogos em Full HD e 2K';
  if (n < 85) return 'Jogos em 2K e 4K';
  return 'Topo de linha';
}

String descrever(String cat, Peca p) {
  switch (cat) {
    case 'cpu':
      return 'Soquete ${p.soquete} · ${p.watts} W · ${perfilDe(p)}';
    case 'placa':
      return 'Soquete ${p.soquete} · memória ${p.memoria}';
    case 'ram':
      return '${p.memoria} · ${p.gb} GB';
    case 'gpu':
      return '${p.watts} W · ${p.comprimento} mm · ${perfilDe(p)}';
    case 'fonte':
      return '${p.watts} W de potência';
    case 'gabinete':
      return 'Aceita placa de vídeo de até ${p.maxGpu} mm';
  }
  return '';
}

Peca? acharPeca(String cat, String id) {
  for (final c in categorias) {
    if (c.chave != cat) continue;
    for (final p in c.itens) {
      if (p.id == id) return p;
    }
  }
  return null;
}

int precoMontagem(Montagem m) {
  var total = 0;
  m.ids.forEach((cat, id) => total += acharPeca(cat, id)?.preco ?? 0);
  return total;
}

const montagens = <Montagem>[
  Montagem(
    'Básico',
    'Internet, estudos, filmes e jogos leves. O mais barato que ainda funciona bem.',
    {
      'cpu': 'c20',
      'placa': 'm18',
      'ram': 'r06',
      'gpu': 'g12',
      'fonte': 'f02',
      'gabinete': 'b03',
    },
  ),
  Montagem(
    'Gamer econômico',
    'Jogos atuais em Full HD com boa qualidade, sem gastar muito.',
    {
      'cpu': 'c17',
      'placa': 'm16',
      'ram': 'r06',
      'gpu': 'g20',
      'fonte': 'f04',
      'gabinete': 'b03',
    },
  ),
  Montagem(
    'Gamer intermediário',
    'Jogos em 2K com qualidade alta e boa folga para o futuro.',
    {
      'cpu': 'c26',
      'placa': 'm23',
      'ram': 'r11',
      'gpu': 'g23',
      'fonte': 'f05',
      'gabinete': 'b03',
    },
  ),
  Montagem(
    'Gamer top',
    'Tudo no máximo em 2K e 4K, com um dos melhores processadores para jogos.',
    {
      'cpu': 'c27',
      'placa': 'm24',
      'ram': 'r11',
      'gpu': 'g37',
      'fonte': 'f07',
      'gabinete': 'b04',
    },
  ),
  Montagem(
    'Xeon econômico',
    'Trabalho, edição e várias tarefas ao mesmo tempo gastando pouco, com processador de servidor.',
    {
      'cpu': 'c38',
      'placa': 'm29',
      'ram': 'r07',
      'gpu': 'g13',
      'fonte': 'f04',
      'gabinete': 'b03',
    },
  ),
  Montagem(
    'Profissional',
    'Edição 8K, 3D, inteligência artificial e trabalho pesado. O topo do topo.',
    {
      'cpu': 'c41',
      'placa': 'm30',
      'ram': 'r14',
      'gpu': 'g29',
      'fonte': 'f09',
      'gabinete': 'b05',
    },
  ),
];

const categorias = <Categoria>[
  Categoria('cpu', 'Processador', [
    Peca(
      'c01',
      'Core 2 Quad Q9550',
      60,
      soquete: 'LGA775',
      watts: 95,
      nota: 6,
      dica: 'Processador muito antigo (2008). Só para PC retrô ou uso bem básico.',
    ),
    Peca('c02', 'FX-6300', 120, soquete: 'AM3+', watts: 95, nota: 9),
    Peca(
      'c03',
      'FX-8350',
      350,
      soquete: 'AM3+',
      watts: 125,
      nota: 12,
      dica: 'Esquenta bastante e gasta muita energia para o desempenho que entrega.',
    ),
    Peca('c04', 'Core i5-3470', 250, soquete: 'LGA1155', watts: 77, nota: 13),
    Peca('c05', 'Core i7-3770K', 350, soquete: 'LGA1155', watts: 77, nota: 17),
    Peca('c06', 'Core i5-4460', 300, soquete: 'LGA1150', watts: 84, nota: 16),
    Peca('c07', 'Core i7-4790K', 500, soquete: 'LGA1150', watts: 88, nota: 22),
    Peca('c08', 'Core i5-6500', 300, soquete: 'LGA1151', watts: 65, nota: 20),
    Peca('c09', 'Core i7-7700K', 600, soquete: 'LGA1151', watts: 91, nota: 27),
    Peca(
      'c10',
      'Core i5-8400',
      500,
      soquete: 'LGA1151 v2',
      watts: 65,
      nota: 27,
    ),
    Peca(
      'c11',
      'Core i7-9700K',
      800,
      soquete: 'LGA1151 v2',
      watts: 95,
      nota: 33,
    ),
    Peca('c12', 'Core i5-10400F', 550, soquete: 'LGA1200', watts: 65, nota: 33),
    Peca(
      'c13',
      'Core i7-10700K',
      1000,
      soquete: 'LGA1200',
      watts: 125,
      nota: 40,
    ),
    Peca('c14', 'Core i5-11400F', 700, soquete: 'LGA1200', watts: 65, nota: 40),
    Peca('c15', 'Ryzen 5 3600', 600, soquete: 'AM4', watts: 65, nota: 36),
    Peca('c16', 'Ryzen 5 5500', 500, soquete: 'AM4', watts: 65, nota: 40),
    Peca(
      'c17',
      'Ryzen 5 5600',
      700,
      soquete: 'AM4',
      watts: 65,
      nota: 46,
      rec: true,
      dica: 'Um dos melhores custo-benefício para jogar em Full HD.',
    ),
    Peca('c18', 'Ryzen 7 5700X', 1000, soquete: 'AM4', watts: 65, nota: 50),
    Peca(
      'c19',
      'Ryzen 7 5800X3D',
      1500,
      soquete: 'AM4',
      watts: 105,
      nota: 64,
      dica: 'Ótimo para jogos: a memória extra dentro do processador deixa os jogos mais rápidos.',
    ),
    Peca(
      'c20',
      'Core i3-12100F',
      450,
      soquete: 'LGA1700',
      watts: 58,
      nota: 38,
      rec: true,
      dica: 'Barato e rápido para o dia a dia e jogos leves.',
    ),
    Peca(
      'c21',
      'Core i5-12400F',
      750,
      soquete: 'LGA1700',
      watts: 65,
      nota: 46,
      rec: true,
    ),
    Peca(
      'c22',
      'Core i5-13400F',
      1100,
      soquete: 'LGA1700',
      watts: 65,
      nota: 52,
    ),
    Peca(
      'c23',
      'Core i7-14700K',
      2200,
      soquete: 'LGA1700',
      watts: 253,
      nota: 74,
      dica: 'Muito forte, mas esquenta e gasta bastante energia. Precisa de bom cooler.',
    ),
    Peca(
      'c24',
      'Core i9-14900K',
      3200,
      soquete: 'LGA1700',
      watts: 253,
      nota: 82,
      dica: 'Muito forte, mas esquenta e gasta bastante energia. Precisa de bom cooler.',
    ),
    Peca('c25', 'Ryzen 5 7600', 1100, soquete: 'AM5', watts: 88, nota: 58),
    Peca('c26', 'Ryzen 7 7700', 1700, soquete: 'AM5', watts: 88, nota: 62),
    Peca(
      'c27',
      'Ryzen 7 7800X3D',
      2300,
      soquete: 'AM5',
      watts: 120,
      nota: 86,
      rec: true,
      dica: 'Um dos melhores processadores para jogos, e esquenta pouco para o que entrega.',
    ),
    Peca('c28', 'Ryzen 5 9600X', 1500, soquete: 'AM5', watts: 88, nota: 64),
    Peca(
      'c29',
      'Ryzen 7 9800X3D',
      3200,
      soquete: 'AM5',
      watts: 120,
      nota: 100,
      dica: 'O processador mais forte para jogos do momento.',
    ),
    Peca(
      'c30',
      'Ryzen 9 7950X3D',
      3800,
      soquete: 'AM5',
      watts: 162,
      nota: 88,
      dica: 'Excelente para jogar e trabalhar pesado ao mesmo tempo.',
    ),
    Peca(
      'c31',
      'Ryzen 9 9950X',
      3600,
      soquete: 'AM5',
      watts: 200,
      nota: 84,
      dica: 'Muitos núcleos: ótimo para edição de vídeo, 3D e programação pesada.',
    ),
    Peca(
      'c32',
      'Core Ultra 5 245K',
      1700,
      soquete: 'LGA1851',
      watts: 159,
      nota: 62,
    ),
    Peca(
      'c33',
      'Core Ultra 7 265K',
      2400,
      soquete: 'LGA1851',
      watts: 250,
      nota: 74,
    ),
    Peca(
      'c34',
      'Core Ultra 9 285K',
      3600,
      soquete: 'LGA1851',
      watts: 250,
      nota: 80,
      dica: 'Muito forte para trabalho pesado e edição.',
    ),
    Peca(
      'c35',
      'Xeon E5-2670',
      100,
      soquete: 'LGA2011',
      watts: 115,
      nota: 10,
      dica: 'Processador de servidor, muito barato. Precisa de placa X79 e memória DDR3. Bom para trabalho, fraco em jogos.',
    ),
    Peca(
      'c36',
      'Xeon E5-2680 v2',
      150,
      soquete: 'LGA2011',
      watts: 115,
      nota: 16,
      dica: 'Processador de servidor, muito barato. Precisa de placa X79 e memória DDR3. Bom para trabalho, fraco em jogos.',
    ),
    Peca(
      'c37',
      'Xeon E5-2670 v3',
      250,
      soquete: 'LGA2011-3',
      watts: 120,
      nota: 24,
      dica: 'Processador de servidor com 12 núcleos. Precisa de placa X99 e memória DDR4. Ótimo para trabalho e multitarefa.',
    ),
    Peca(
      'c38',
      'Xeon E5-2680 v4',
      350,
      soquete: 'LGA2011-3',
      watts: 120,
      nota: 30,
      rec: true,
      dica: 'Processador de servidor com 14 núcleos e preço baixo. Precisa de placa X99. Ótimo para trabalho e edição, rende menos em jogos.',
    ),
    Peca(
      'c39',
      'Xeon E5-2690 v4',
      500,
      soquete: 'LGA2011-3',
      watts: 135,
      nota: 33,
      dica: 'Processador de servidor com 14 núcleos, um pouco mais rápido. Precisa de placa X99.',
    ),
    Peca(
      'c40',
      'Xeon E5-2699 v4',
      800,
      soquete: 'LGA2011-3',
      watts: 145,
      nota: 36,
      dica: '22 núcleos: excelente para renderizar, rodar máquinas virtuais e editar pesado. Precisa de placa X99.',
    ),
    Peca(
      'c41',
      'Threadripper 7970X',
      17000,
      soquete: 'sTR5',
      watts: 350,
      nota: 85,
      dica: 'Processador de estação de trabalho profissional (32 núcleos). Para 3D, IA e edição 8K. Usa placa e memória de servidor.',
    ),
  ]),
  Categoria('placa', 'Placa-mãe', [
    Peca('m01', 'G41 DDR2', 100, soquete: 'LGA775', memoria: 'DDR2'),
    Peca('m02', '970', 250, soquete: 'AM3+', memoria: 'DDR3'),
    Peca('m03', 'H61M', 200, soquete: 'LGA1155', memoria: 'DDR3'),
    Peca('m04', 'Z77', 350, soquete: 'LGA1155', memoria: 'DDR3'),
    Peca('m05', 'H81M', 250, soquete: 'LGA1150', memoria: 'DDR3'),
    Peca('m06', 'Z97', 450, soquete: 'LGA1150', memoria: 'DDR3'),
    Peca('m07', 'H110M', 300, soquete: 'LGA1151', memoria: 'DDR4'),
    Peca('m08', 'Z270', 600, soquete: 'LGA1151', memoria: 'DDR4'),
    Peca('m09', 'B360M', 350, soquete: 'LGA1151 v2', memoria: 'DDR4'),
    Peca('m10', 'Z390', 700, soquete: 'LGA1151 v2', memoria: 'DDR4'),
    Peca('m11', 'H410M', 450, soquete: 'LGA1200', memoria: 'DDR4'),
    Peca('m12', 'B560M', 550, soquete: 'LGA1200', memoria: 'DDR4'),
    Peca('m13', 'Z490', 800, soquete: 'LGA1200', memoria: 'DDR4'),
    Peca('m14', 'A320M', 300, soquete: 'AM4', memoria: 'DDR4'),
    Peca('m15', 'B450M', 450, soquete: 'AM4', memoria: 'DDR4'),
    Peca('m16', 'B550M', 600, soquete: 'AM4', memoria: 'DDR4', rec: true),
    Peca('m17', 'X570', 1100, soquete: 'AM4', memoria: 'DDR4'),
    Peca('m18', 'H610M', 500, soquete: 'LGA1700', memoria: 'DDR4', rec: true),
    Peca(
      'm19',
      'B660M DDR4',
      650,
      soquete: 'LGA1700',
      memoria: 'DDR4',
      rec: true,
    ),
    Peca(
      'm20',
      'B760M DDR5',
      850,
      soquete: 'LGA1700',
      memoria: 'DDR5',
      rec: true,
    ),
    Peca('m21', 'Z790', 1500, soquete: 'LGA1700', memoria: 'DDR5'),
    Peca('m22', 'A620M', 700, soquete: 'AM5', memoria: 'DDR5'),
    Peca('m23', 'B650M', 900, soquete: 'AM5', memoria: 'DDR5', rec: true),
    Peca('m24', 'B850M', 1200, soquete: 'AM5', memoria: 'DDR5'),
    Peca('m25', 'X870E', 2000, soquete: 'AM5', memoria: 'DDR5'),
    Peca('m26', 'B860M', 1100, soquete: 'LGA1851', memoria: 'DDR5'),
    Peca('m27', 'Z890', 2200, soquete: 'LGA1851', memoria: 'DDR5'),
    Peca(
      'm28',
      'X79 para Xeon',
      400,
      soquete: 'LGA2011',
      memoria: 'DDR3',
      dica: 'Placa para Xeon da geração antiga. Usa memória DDR3.',
    ),
    Peca(
      'm29',
      'X99 para Xeon',
      500,
      soquete: 'LGA2011-3',
      memoria: 'DDR4',
      rec: true,
      dica: 'Placa muito usada para montar PC de trabalho barato com Xeon.',
    ),
    Peca(
      'm30',
      'TRX50',
      6500,
      soquete: 'sTR5',
      memoria: 'DDR5 ECC',
      dica: 'Placa profissional. Só aceita memória de servidor (DDR5 ECC).',
    ),
  ]),
  Categoria('ram', 'Memória RAM', [
    Peca('r01', '4 GB DDR2 800', 60, memoria: 'DDR2', gb: 4),
    Peca('r02', '4 GB DDR3 1333', 50, memoria: 'DDR3', gb: 4),
    Peca('r03', '8 GB DDR3 1600', 100, memoria: 'DDR3', gb: 8),
    Peca('r04', '16 GB DDR3 1600', 180, memoria: 'DDR3', gb: 16),
    Peca('r05', '8 GB DDR4 2666', 130, memoria: 'DDR4', gb: 8),
    Peca(
      'r06',
      '16 GB DDR4 3200',
      200,
      memoria: 'DDR4',
      gb: 16,
      rec: true,
      dica: 'Quantidade ideal para a maioria das pessoas.',
    ),
    Peca('r07', '32 GB DDR4 3200', 380, memoria: 'DDR4', gb: 32, rec: true),
    Peca('r08', '64 GB DDR4 3200', 800, memoria: 'DDR4', gb: 64),
    Peca('r09', '16 GB DDR5 5600', 320, memoria: 'DDR5', gb: 16),
    Peca('r10', '32 GB DDR5 5600', 600, memoria: 'DDR5', gb: 32),
    Peca('r11', '32 GB DDR5 6000', 700, memoria: 'DDR5', gb: 32, rec: true),
    Peca('r12', '64 GB DDR5 6000', 1300, memoria: 'DDR5', gb: 64),
    Peca(
      'r13',
      '96 GB DDR5 6000',
      2000,
      memoria: 'DDR5',
      gb: 96,
      dica: 'Ideal para edição pesada e muitas tarefas abertas ao mesmo tempo.',
    ),
    Peca(
      'r14',
      '64 GB DDR5 ECC',
      3500,
      memoria: 'DDR5 ECC',
      gb: 64,
      dica: 'Memória de servidor. Só funciona em placa profissional.',
    ),
    Peca(
      'r15',
      '128 GB DDR5 ECC',
      7000,
      memoria: 'DDR5 ECC',
      gb: 128,
      dica: 'Memória de servidor. Só funciona em placa profissional.',
    ),
  ]),
  Categoria('gpu', 'Placa de vídeo', [
    Peca(
      'g01',
      'GT 710',
      150,
      watts: 19,
      comprimento: 145,
      nota: 1,
      dica: 'Serve só para ligar o monitor. Não é para jogos.',
    ),
    Peca('g02', 'GT 1030', 350, watts: 30, comprimento: 145, nota: 4),
    Peca('g03', 'GTX 750 Ti', 200, watts: 60, comprimento: 145, nota: 6),
    Peca('g04', 'GTX 1050 Ti', 350, watts: 75, comprimento: 175, nota: 10),
    Peca('g05', 'GTX 1060 6GB', 500, watts: 120, comprimento: 250, nota: 18),
    Peca('g06', 'RX 580 8GB', 450, watts: 185, comprimento: 240, nota: 20),
    Peca('g07', 'GTX 1650', 900, watts: 75, comprimento: 200, nota: 14),
    Peca('g08', 'GTX 1660 Super', 1100, watts: 125, comprimento: 230, nota: 24),
    Peca('g09', 'RTX 2060', 1100, watts: 160, comprimento: 230, nota: 29),
    Peca('g10', 'RTX 3050', 1100, watts: 130, comprimento: 240, nota: 22),
    Peca('g11', 'RX 6500 XT', 800, watts: 107, comprimento: 190, nota: 15),
    Peca(
      'g12',
      'RX 6600',
      1400,
      watts: 132,
      comprimento: 240,
      nota: 31,
      rec: true,
      dica: 'Ótimo custo-benefício para jogar em Full HD.',
    ),
    Peca('g13', 'RTX 3060', 1700, watts: 170, comprimento: 240, nota: 34),
    Peca('g14', 'RTX 3060 Ti', 2200, watts: 200, comprimento: 242, nota: 40),
    Peca('g15', 'RX 6700 XT', 2300, watts: 230, comprimento: 267, nota: 42),
    Peca('g16', 'RTX 3070', 2500, watts: 220, comprimento: 242, nota: 46),
    Peca('g17', 'RTX 3080', 3500, watts: 320, comprimento: 285, nota: 54),
    Peca(
      'g18',
      'RTX 4060',
      1900,
      watts: 115,
      comprimento: 240,
      nota: 38,
      rec: true,
      dica: 'Boa para Full HD e gasta pouca energia.',
    ),
    Peca('g19', 'RX 7600', 1700, watts: 165, comprimento: 240, nota: 36),
    Peca('g20', 'RTX 4060 Ti', 2400, watts: 160, comprimento: 245, nota: 44),
    Peca('g21', 'RX 7700 XT', 2900, watts: 245, comprimento: 267, nota: 50),
    Peca('g22', 'RTX 4070', 3600, watts: 200, comprimento: 244, nota: 54),
    Peca(
      'g23',
      'RX 7800 XT',
      3300,
      watts: 263,
      comprimento: 267,
      nota: 58,
      rec: true,
      dica: 'Muito boa para jogar em 2K com qualidade alta.',
    ),
    Peca(
      'g24',
      'RTX 4070 Super',
      4200,
      watts: 220,
      comprimento: 245,
      nota: 60,
      rec: true,
    ),
    Peca('g25', 'RX 7900 GRE', 3800, watts: 260, comprimento: 276, nota: 62),
    Peca(
      'g26',
      'RTX 4070 Ti Super',
      5500,
      watts: 285,
      comprimento: 305,
      nota: 68,
    ),
    Peca('g27', 'RTX 4080 Super', 8000, watts: 320, comprimento: 310, nota: 76),
    Peca('g28', 'RX 7900 XTX', 6500, watts: 355, comprimento: 287, nota: 74),
    Peca(
      'g29',
      'RTX 4090',
      14000,
      watts: 450,
      comprimento: 336,
      nota: 90,
      dica: 'Muito potente e muito grande. Exige fonte forte e gabinete espaçoso.',
    ),
    Peca('g30', 'RTX 5060', 2300, watts: 145, comprimento: 240, nota: 42),
    Peca('g31', 'RTX 5060 Ti', 2900, watts: 180, comprimento: 245, nota: 50),
    Peca('g32', 'RX 9060 XT', 2600, watts: 160, comprimento: 245, nota: 50),
    Peca('g33', 'RTX 5070', 5000, watts: 250, comprimento: 300, nota: 62),
    Peca('g34', 'RX 9070', 4500, watts: 220, comprimento: 310, nota: 68),
    Peca(
      'g35',
      'RX 9070 XT',
      5000,
      watts: 304,
      comprimento: 320,
      nota: 74,
      rec: true,
      dica: 'Excelente para jogar em 2K e 4K.',
    ),
    Peca('g36', 'RTX 5070 Ti', 6500, watts: 300, comprimento: 300, nota: 76),
    Peca('g37', 'RTX 5080', 9000, watts: 360, comprimento: 310, nota: 82),
    Peca(
      'g38',
      'RTX 5090',
      18000,
      watts: 575,
      comprimento: 340,
      nota: 100,
      dica: 'A placa de vídeo mais potente do mercado. Para 4K no máximo, IA e trabalho profissional. Exige fonte de 1200 W ou mais.',
    ),
  ]),
  Categoria('fonte', 'Fonte', [
    Peca('f01', 'Fonte 300W', 120, watts: 300),
    Peca('f02', 'Fonte 450W', 200, watts: 450),
    Peca('f03', 'Fonte 500W', 240, watts: 500),
    Peca('f04', 'Fonte 550W', 280, watts: 550),
    Peca('f05', 'Fonte 650W', 350, watts: 650, rec: true),
    Peca('f06', 'Fonte 750W', 450, watts: 750, rec: true),
    Peca('f07', 'Fonte 850W', 600, watts: 850, rec: true),
    Peca('f08', 'Fonte 1000W', 900, watts: 1000),
    Peca('f09', 'Fonte 1200W', 1300, watts: 1200),
    Peca('f10', 'Fonte 1600W', 2000, watts: 1600),
  ]),
  Categoria('gabinete', 'Gabinete', [
    Peca(
      'b01',
      'Gabinete mini ITX',
      250,
      maxGpu: 200,
      dica: 'Pequeno: cabe só placa de vídeo curta.',
    ),
    Peca('b02', 'Gabinete compacto', 250, maxGpu: 230),
    Peca('b03', 'Gabinete médio', 350, maxGpu: 300, rec: true),
    Peca('b04', 'Gabinete gamer grande', 500, maxGpu: 380, rec: true),
    Peca(
      'b05',
      'Gabinete full tower',
      800,
      maxGpu: 420,
      dica: 'Enorme: cabe qualquer placa de vídeo e muitos ventiladores.',
    ),
  ]),
];
