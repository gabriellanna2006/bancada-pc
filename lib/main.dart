import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tela_bancada.dart';
import 'tema.dart';

void main() => runApp(const BancadaApp());

class BancadaApp extends StatelessWidget {
  const BancadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bancada PC · Simulador de montagem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Cores.fundo,
        colorScheme: const ColorScheme.dark(primary: Cores.destaque),
        fontFamily: GoogleFonts.dmSans().fontFamily,
      ),
      home: const TelaBancada(),
    );
  }
}
