import 'package:flutter/material.dart';
import 'tools/svg_tagger_tool.dart';

void main() {
  runApp(const SvgTaggerApp());
}

class SvgTaggerApp extends StatelessWidget {
  const SvgTaggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVG Tagger Tool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SvgTaggerTool(),
      debugShowCheckedModeBanner: false,
    );
  }
}
