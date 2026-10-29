import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'lojas.dart';
import 'pecas.dart';
import 'regras.dart';
import 'tema.dart';

class TelaBancada extends StatefulWidget {
  const TelaBancada({super.key});

  @override
  State<TelaBancada> createState() => _TelaBancadaState();
}

class _TelaBancadaState extends State<TelaBancada> {
  final Map<String, Peca> escolhidas = {};
  bool mostrarLinks = false;
  final GlobalKey linksKey = GlobalKey();
  final GlobalKey pecasKey = GlobalKey();

  int get total => escolhidas.values.fold(0, (soma, p) => soma + p.preco);

  bool get celular => MediaQuery.sizeOf(context).width < 600;

  void _toast(IconData icone, Color cor, String titulo, [String? sub]) {
    final m = ScaffoldMessenger.of(context);
    final largura = MediaQuery.sizeOf(context).width;
    final lateral = largura > 480 ? (largura - 440) / 2 : 16.0;

    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Cores.superficie,
        elevation: 8,
        duration: const Duration(milliseconds: 2800),
        margin: EdgeInsets.fromLTRB(lateral, 0, lateral, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: cor),
        ),
        content: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: cor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Cores.texto,
                    ),
                  ),
                  if (sub != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        sub,
                        style: const TextStyle(
                          color: Cores.textoSuave,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void escolher(String cat, Peca? p) {
    setState(() {
      if (p == null) {
        escolhidas.remove(cat);
      } else {
        escolhidas[cat] = p;
      }
    });
  }

  void aplicarMontagem(Montagem m) {
    setState(() {
      escolhidas.clear();
      m.ids.forEach((cat, id) {
        final p = acharPeca(cat, id);
        if (p != null) escolhidas[cat] = p;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = pecasKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    _toast(
      Icons.check_rounded,
      Cores.ok,
      'Montagem "${m.nome}" carregada',
      'Você pode trocar qualquer peça.',
    );
  }

  void limpar() {
    if (escolhidas.isEmpty) {
      _toast(
        Icons.info_outline_rounded,
        Cores.destaque,
        'A bancada já está vazia',
        'Escolha as peças para começar.',
      );
      return;
    }
    setState(() {
      escolhidas.clear();
      mostrarLinks = false;
    });
    _toast(
      Icons.check_rounded,
      Cores.ok,
      'Bancada limpa com sucesso!',
      'Todas as peças foram removidas. Monte um novo PC quando quiser.',
    );
  }

  void gerarLinks() {
    if (escolhidas.isEmpty) {
      _toast(
        Icons.warning_amber_rounded,
        Cores.aviso,
        'Escolha pelo menos uma peça',
        'Depois é só gerar os links das lojas.',
      );
      return;
    }
    setState(() => mostrarLinks = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = linksKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
        );
      }
    });
  }

  Future<void> abrir(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> copiarLinks() async {
    await Clipboard.setData(ClipboardData(text: gerarTexto(escolhidas)));
    if (!mounted) return;
    _toast(
      Icons.check_rounded,
      Cores.ok,
      'Links copiados!',
      'Agora é só colar onde quiser.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final regras = verificar(escolhidas);
    final cel = celular;
    final lateral = cel ? 16.0 : 20.0;

    Widget secao(Widget filho) => SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: lateral),
            child: RepaintBoundary(child: filho),
          ),
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Cores.fundo,
            surfaceTintColor: Colors.transparent,
            shape: const Border(bottom: BorderSide(color: Cores.borda)),
            title: Text(
              'Bancada PC',
              style: GoogleFonts.spaceGrotesk(
                fontSize: cel ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: Cores.destaque,
              ),
            ),
            actions: [
              if (cel)
                IconButton(
                  onPressed: limpar,
                  tooltip: 'Limpar bancada',
                  icon: const Icon(Icons.delete_outline, color: Cores.texto),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: OutlinedButton(
                    onPressed: limpar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Cores.texto,
                      backgroundColor: Cores.superficie,
                      side: const BorderSide(color: Cores.borda),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Limpar bancada'),
                  ),
                ),
            ],
          ),
          secao(_hero()),
          secao(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _montagensProntas(),
                Container(
                  key: pecasKey,
                  child: _titulo(
                    'Escolha as peças',
                    'Cada lista vai da peça mais antiga para a mais nova. A peça com ★ é uma boa escolha para a maioria das pessoas.',
                  ),
                ),
              ],
            ),
          ),
          secao(_layout(regras)),
          secao(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _analise(),
                if (mostrarLinks && escolhidas.isNotEmpty) _links(),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _titulo(String texto, [String? sub]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texto,
            style: GoogleFonts.spaceGrotesk(
              fontSize: celular ? 20 : 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (sub != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                sub,
                style: TextStyle(
                  color: Cores.textoSuave,
                  fontSize: celular ? 13.5 : 14.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hero() {
    final cel = celular;
    return Padding(
      padding: EdgeInsets.only(top: cel ? 28 : 48, bottom: cel ? 24 : 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monte seu PC peça por peça.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: cel ? 30 : 40,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: cel ? -0.8 : -1.2,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Não precisa entender de computador. Escolha as peças, veja na hora se elas combinam e descubra se alguma está limitando as outras.',
              style: TextStyle(
                color: Cores.textoSuave,
                fontSize: cel ? 15 : 16.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _montagensProntas() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo(
            'Não sabe por onde começar?',
            'Escolha uma montagem pronta e depois troque o que quiser.',
          ),
          LayoutBuilder(
            builder: (context, cons) {
              const espaco = 12.0;
              final colunas = (cons.maxWidth / 260).floor().clamp(1, 3);
              final largura =
                  (cons.maxWidth - espaco * (colunas - 1)) / colunas;
              return Wrap(
                spacing: espaco,
                runSpacing: espaco,
                children: [
                  for (final m in montagens) _cartaoMontagem(m, largura),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _cartaoMontagem(Montagem m, double largura) {
    return SizedBox(
      width: largura,
      child: Material(
        color: Cores.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Cores.borda),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => aplicarMontagem(m),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.nome,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  m.descricao,
                  style: const TextStyle(
                    color: Cores.textoSuave,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'a partir de ${dinheiro(precoMontagem(m))}',
                  style: const TextStyle(
                    color: Cores.destaque,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Usar esta montagem →',
                  style: TextStyle(
                    color: Cores.destaque,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _layout(List<Regra> regras) {
    return LayoutBuilder(
      builder: (context, cons) {
        final largo = cons.maxWidth > 860;
        final pecas = _pecas(regras);
        final resumo = _resumo(regras);
        if (largo) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: pecas),
              const SizedBox(width: 24),
              SizedBox(width: 340, child: resumo),
            ],
          );
        }
        return Column(children: [pecas, const SizedBox(height: 24), resumo]);
      },
    );
  }

  Widget _pecas(List<Regra> regras) {
    final erros = <String>{
      for (final r in regras.where((r) => r.nivel == Nivel.erro)) ...r.pecas,
    };
    final avisos = <String>{
      for (final r in regras.where((r) => r.nivel == Nivel.aviso)) ...r.pecas,
    };

    return LayoutBuilder(
      builder: (context, cons) {
        const espaco = 16.0;
        final colunas = (cons.maxWidth / 280).floor().clamp(1, 4);
        final largura = (cons.maxWidth - espaco * (colunas - 1)) / colunas;

        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final cat in categorias)
              SizedBox(
                width: largura,
                child: _cartao(
                  cat,
                  erros.contains(cat.chave),
                  avisos.contains(cat.chave),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _cartao(Categoria cat, bool erro, bool avisoAmarelo) {
    final escolhida = escolhidas[cat.chave];
    final corBorda = erro
        ? Cores.erro
        : (avisoAmarelo ? Cores.aviso : Cores.borda);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: corBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cat.titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Cores.fundo,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Cores.borda),
            ),
            child: DropdownButton<String>(
              value: escolhida?.id,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Cores.superficie,
              menuMaxHeight: 420,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Escolher...'),
                ),
                for (final p in cat.itens)
                  DropdownMenuItem<String>(
                    value: p.id,
                    child: Text(
                      '${p.rec ? '★ ' : ''}${p.nome} · ${dinheiro(p.preco)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                final p = id == null
                    ? null
                    : cat.itens.firstWhere((i) => i.id == id);
                escolher(cat.chave, p);
              },
            ),
          ),
          if (escolhida != null) ...[
            const SizedBox(height: 8),
            Text(
              descrever(cat.chave, escolhida),
              style: const TextStyle(color: Cores.textoSuave, fontSize: 13.5),
            ),
            if (escolhida.dica != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  escolhida.dica!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _resumo(List<Regra> regras) {
    final cpu = escolhidas['cpu'];
    final gpu = escolhidas['gpu'];
    final temErro = regras.any((r) => r.nivel == Nivel.erro);
    final temAviso = regras.any((r) => r.nivel == Nivel.aviso);
    final completo = categorias.every((c) => escolhidas.containsKey(c.chave));

    String msg;
    Color? corVeredito;
    if (temErro) {
      msg = 'Há peças incompatíveis. Troque as que estão marcadas em vermelho.';
      corVeredito = Cores.erro;
    } else if (completo && temAviso) {
      msg =
          'Montagem compatível, mas há avisos. Confira as verificações acima.';
      corVeredito = Cores.aviso;
    } else if (completo) {
      msg = 'Montagem compatível! Seu PC está pronto para ligar.';
      corVeredito = Cores.ok;
    } else {
      msg = 'Escolha todas as peças para finalizar a montagem.';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(celular ? 16 : 20),
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Cores.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua montagem',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final cat in categorias) _linhaLista(cat),
          const Divider(color: Cores.borda, height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('Total'),
              Text(
                dinheiro(total),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Cores.destaque,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Preços aproximados.',
              style: TextStyle(color: Cores.textoSuave, fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Verificações',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (cpu != null && gpu != null)
            _info('Consumo estimado: ${consumoEstimado(cpu, gpu)} W'),
          if (regras.isEmpty)
            _info('Escolha as peças para ver as verificações.'),
          for (final r in regras) _checagem(r),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Cores.fundo,
              borderRadius: BorderRadius.circular(10),
              border: corVeredito == null
                  ? null
                  : Border.all(color: corVeredito),
            ),
            child: Text(
              msg,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: corVeredito ?? Cores.texto,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: gerarLinks,
              style: FilledButton.styleFrom(
                backgroundColor: Cores.destaque,
                foregroundColor: const Color(0xFF04222A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Gerar links das lojas',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaLista(Categoria cat) {
    final p = escolhidas[cat.chave];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '${cat.titulo}: ${p?.nome ?? 'não escolhida'}',
              style: TextStyle(
                fontSize: 14.5,
                color: p == null ? Cores.textoSuave : Cores.texto,
              ),
            ),
          ),
          if (p != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                dinheiro(p.preco),
                style: const TextStyle(color: Cores.textoSuave, fontSize: 14.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _info(String texto) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Text(
      texto,
      style: const TextStyle(color: Cores.textoSuave, fontSize: 14),
    ),
  );

  Widget _checagem(Regra r) {
    final cor = r.nivel == Nivel.ok
        ? Cores.ok
        : (r.nivel == Nivel.aviso ? Cores.aviso : Cores.erro);
    final icone = r.nivel == Nivel.ok
        ? '✓'
        : (r.nivel == Nivel.aviso ? '!' : '✕');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              icone,
              style: TextStyle(color: cor, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(r.texto, style: TextStyle(color: cor, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _analise() {
    final cpu = escolhidas['cpu'];
    final gpu = escolhidas['gpu'];
    final ram = escolhidas['ram'];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 28),
      padding: EdgeInsets.all(celular ? 16 : 22),
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Cores.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análise do seu PC',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mostra se as peças estão no mesmo nível ou se alguma está limitando as outras. Esse limite se chama "gargalo".',
            style: TextStyle(color: Cores.textoSuave, fontSize: 14.5),
          ),
          const SizedBox(height: 20),
          if (cpu == null || gpu == null)
            const Text(
              'Escolha o processador e a placa de vídeo para ver o gráfico de gargalo.',
              style: TextStyle(color: Cores.textoSuave),
            )
          else ...[
            LayoutBuilder(
              builder: (context, cons) {
                final g = calcularGargalo(cpu, gpu);
                final barras = _barras(cpu, gpu, ram);
                final card = _gargaloCard(g);
                if (cons.maxWidth > 760) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: barras),
                      const SizedBox(width: 32),
                      Expanded(child: card),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [barras, const SizedBox(height: 24), card],
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Cores.fundo,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Cores.borda),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seu PC serve para:',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(usoRecomendado(cpu, gpu)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Valores estimados para jogos. O resultado real muda conforme o jogo, a resolução e as configurações. Em trabalho pesado (render, edição), processadores com muitos núcleos, como Xeon e Threadripper, rendem mais do que a nota mostra.',
              style: TextStyle(color: Cores.textoSuave, fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _barras(Peca cpu, Peca gpu, Peca? ram) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Força de cada peça',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 14),
        _barra(
          'Processador',
          cpu.nome,
          '${cpu.nota} / 100',
          cpu.nota!,
          Cores.destaque,
        ),
        _barra(
          'Placa de vídeo',
          gpu.nome,
          '${gpu.nota} / 100',
          gpu.nota!,
          Cores.roxo,
        ),
        _barra(
          'Memória RAM',
          ram?.nome,
          ram == null ? 'não escolhida' : '${ram.gb} GB',
          ram == null ? 0 : ramNota(ram.gb!),
          Cores.aviso,
        ),
      ],
    );
  }

  Widget _barra(
    String rotulo,
    String? nome,
    String valor,
    int nota,
    Color cor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rotulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                valor,
                style: const TextStyle(color: Cores.textoSuave, fontSize: 13.5),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: nota / 100),
              duration: const Duration(milliseconds: 500),
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 14,
                backgroundColor: Cores.fundo,
                valueColor: AlwaysStoppedAnimation<Color>(cor),
              ),
            ),
          ),
          if (nome != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                nome,
                style: const TextStyle(color: Cores.textoSuave, fontSize: 12.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gargaloCard(Gargalo g) {
    final cor = g.percentual < 10
        ? Cores.ok
        : (g.percentual < 30 ? Cores.aviso : Cores.erro);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gargalo',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${g.percentual}%',
              style: GoogleFonts.spaceGrotesk(
                fontSize: celular ? 38 : 44,
                fontWeight: FontWeight.w700,
                color: cor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                g.titulo,
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const Text(
          'de diferença de força entre processador e placa de vídeo',
          style: TextStyle(color: Cores.textoSuave, fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        Text(
          g.explicacao,
          style: const TextStyle(color: Cores.textoSuave, fontSize: 14.5),
        ),
        const SizedBox(height: 18),
        _medidor(g),
      ],
    );
  }

  Widget _medidor(Gargalo g) {
    final x = (g.posicao + 1) / 2;
    return Column(
      children: [
        SizedBox(
          height: 28,
          child: LayoutBuilder(
            builder: (context, cons) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [
                            Cores.erro,
                            Cores.aviso,
                            Cores.ok,
                            Cores.aviso,
                            Cores.erro,
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    left: (cons.maxWidth - 14) * x,
                    top: 4,
                    child: Container(
                      width: 14,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Cores.texto,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Cores.fundo, width: 2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Processador limita',
                style: TextStyle(color: Cores.textoSuave, fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                'Equilibrado',
                textAlign: TextAlign.center,
                style: TextStyle(color: Cores.textoSuave, fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                'Placa de vídeo limita',
                textAlign: TextAlign.right,
                style: TextStyle(color: Cores.textoSuave, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _links() {
    return Container(
      key: linksKey,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 28),
      padding: EdgeInsets.all(celular ? 16 : 22),
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Cores.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Links das lojas',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cada link abre a busca da peça na loja. Confira o modelo e o preço antes de comprar.',
            style: TextStyle(color: Cores.textoSuave, fontSize: 14.5),
          ),
          const SizedBox(height: 16),
          for (final cat in categorias)
            if (escolhidas[cat.chave] != null) _blocoLinks(cat),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: copiarLinks,
            child: const Text('Copiar todos os links'),
          ),
        ],
      ),
    );
  }

  Widget _blocoLinks(Categoria cat) {
    final p = escolhidas[cat.chave]!;
    final termo = termoBusca(cat.chave, p);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Cores.borda)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${cat.titulo}: ${p.nome}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 0,
            children: [
              for (final loja in lojas)
                TextButton(
                  onPressed: () => abrir(loja.url(termo)),
                  child: Text(
                    loja.nome,
                    style: const TextStyle(color: Cores.destaque),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
