import 'pecas.dart';

enum Nivel { ok, aviso, erro }

class Regra {
  final Nivel nivel;
  final String texto;
  final List<String> pecas;

  const Regra(this.nivel, this.texto, this.pecas);
}

class Gargalo {
  final int percentual;
  final String lado;
  final String titulo;
  final String explicacao;
  final double posicao;

  const Gargalo(
    this.percentual,
    this.lado,
    this.titulo,
    this.explicacao,
    this.posicao,
  );
}

int consumoEstimado(Peca cpu, Peca gpu) => cpu.watts! + gpu.watts! + 100;

int fonteRecomendada(Peca cpu, Peca gpu) =>
    (consumoEstimado(cpu, gpu) * 13 + 9) ~/ 10;

int ramRecomendada(Peca cpu, Peca gpu) {
  final media = (cpu.nota! + gpu.nota!) / 2;
  if (media < 15) return 4;
  if (media < 35) return 8;
  if (media < 60) return 16;
  return 32;
}

int ramNota(int gb) {
  if (gb >= 96) return 100;
  if (gb >= 64) return 90;
  if (gb >= 32) return 75;
  if (gb >= 16) return 50;
  if (gb >= 8) return 25;
  return 10;
}

Gargalo calcularGargalo(Peca cpu, Peca gpu) {
  final c = cpu.nota!;
  final g = gpu.nota!;
  final maior = c > g ? c : g;
  final menor = c > g ? g : c;
  final pct = ((maior - menor) * 100 / maior).round();
  final pos = (c < g ? -1 : 1) * pct / 100;

  if (pct < 10) {
    return Gargalo(
      pct,
      'equilibrado',
      'Combinação equilibrada',
      'Processador e placa de vídeo estão no mesmo nível. Nenhuma das duas peças está sendo desperdiçada.',
      pos,
    );
  }

  if (c < g) {
    if (pct < 30) {
      return Gargalo(
        pct,
        'cpu',
        'Gargalo leve no processador',
        'O processador está um pouco abaixo da placa de vídeo. Em alguns jogos você pode perder cerca de $pct% do potencial dela.',
        pos,
      );
    }
    if (pct < 50) {
      return Gargalo(
        pct,
        'cpu',
        'Gargalo moderado no processador',
        'A placa de vídeo é bem mais forte que o processador e vai ficar esperando por ele. Um processador melhor deixaria o PC bem mais rápido.',
        pos,
      );
    }
    return Gargalo(
      pct,
      'cpu',
      'Gargalo forte no processador',
      'A placa de vídeo é muito mais forte que o processador. Você paga por um desempenho que não consegue usar. Troque o processador por um mais forte ou escolha uma placa de vídeo mais simples.',
      pos,
    );
  }

  if (pct < 30) {
    return Gargalo(
      pct,
      'gpu',
      'Placa de vídeo um pouco mais fraca',
      'O processador tem uma pequena folga. Está bom assim, e no futuro uma placa melhor vai aproveitar esse processador.',
      pos,
    );
  }
  if (pct < 50) {
    return Gargalo(
      pct,
      'gpu',
      'A placa de vídeo é o ponto fraco',
      'O processador é bem mais forte que a placa de vídeo. Para jogos, vale investir mais na placa de vídeo.',
      pos,
    );
  }
  return Gargalo(
    pct,
    'gpu',
    'Processador muito mais forte que a placa de vídeo',
    'Para jogos, a placa de vídeo vai limitar bastante o PC. Para trabalho e uso comum não tem problema, mas se a ideia é jogar, escolha uma placa melhor.',
    pos,
  );
}

String usoRecomendado(Peca cpu, Peca gpu) {
  final m = (cpu.nota! + gpu.nota!) / 2;
  if (m < 10)
    return 'Só o básico: internet, vídeos e trabalhos simples. Não é indicado para jogos.';
  if (m < 25) return 'Uso do dia a dia, estudos e jogos leves ou antigos.';
  if (m < 40) return 'Jogos populares em Full HD com qualidade baixa a média.';
  if (m < 55) return 'Jogos atuais em Full HD com boa qualidade.';
  if (m < 70) return 'Jogos atuais em Full HD e 2K com qualidade alta.';
  if (m < 85) return 'Jogos em 2K e 4K, streaming e edição de vídeo.';
  return 'Desempenho máximo: 4K, edição profissional, 3D e trabalho pesado.';
}

List<Regra> verificar(Map<String, Peca> e) {
  final r = <Regra>[];
  final cpu = e['cpu'];
  final placa = e['placa'];
  final ram = e['ram'];
  final gpu = e['gpu'];
  final fonte = e['fonte'];
  final gabinete = e['gabinete'];

  if (cpu != null && placa != null) {
    final ok = cpu.soquete == placa.soquete;
    r.add(
      Regra(
        ok ? Nivel.ok : Nivel.erro,
        ok
            ? 'Soquete ${cpu.soquete} combina com a placa-mãe.'
            : 'O processador usa ${cpu.soquete}, mas a placa-mãe usa ${placa.soquete}.',
        ['cpu', 'placa'],
      ),
    );
  }

  if (ram != null && placa != null) {
    final ok = ram.memoria == placa.memoria;
    r.add(
      Regra(
        ok ? Nivel.ok : Nivel.erro,
        ok
            ? 'A memória ${ram.memoria} é aceita pela placa-mãe.'
            : 'A RAM é ${ram.memoria}, mas a placa-mãe só aceita ${placa.memoria}.',
        ['ram', 'placa'],
      ),
    );
  }

  if (cpu != null && gpu != null && fonte != null) {
    final recomendada = fonteRecomendada(cpu, gpu);
    final ok = fonte.watts! >= recomendada;
    r.add(
      Regra(
        ok ? Nivel.ok : Nivel.erro,
        ok
            ? 'Fonte de ${fonte.watts} W atende (recomendado: $recomendada W).'
            : 'Fonte fraca: ${fonte.watts} W, e o recomendado é $recomendada W ou mais.',
        ['fonte'],
      ),
    );
  }

  if (gpu != null && gabinete != null) {
    final ok = gpu.comprimento! <= gabinete.maxGpu!;
    r.add(
      Regra(
        ok ? Nivel.ok : Nivel.erro,
        ok
            ? 'A placa de vídeo (${gpu.comprimento} mm) cabe no gabinete.'
            : 'A placa de vídeo tem ${gpu.comprimento} mm e o gabinete aceita até ${gabinete.maxGpu} mm.',
        ['gpu', 'gabinete'],
      ),
    );
  }

  if (cpu != null && gpu != null && ram != null) {
    final rec = ramRecomendada(cpu, gpu);
    final ok = ram.gb! >= rec;
    r.add(
      Regra(
        ok ? Nivel.ok : Nivel.aviso,
        ok
            ? 'A quantidade de memória (${ram.gb} GB) é adequada.'
            : 'Pouca memória: ${ram.gb} GB. Para essa combinação, o ideal é $rec GB ou mais.',
        ['ram'],
      ),
    );
  }

  if (cpu != null && gpu != null) {
    final g = calcularGargalo(cpu, gpu);
    if (g.lado == 'cpu' && g.percentual >= 30) {
      r.add(
        Regra(
          Nivel.aviso,
          'Gargalo de ${g.percentual}% no processador. Veja a análise abaixo.',
          ['cpu', 'gpu'],
        ),
      );
    }
  }

  return r;
}
