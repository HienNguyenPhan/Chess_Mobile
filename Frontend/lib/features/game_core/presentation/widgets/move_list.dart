import 'package:flutter/material.dart';

class MoveList extends StatelessWidget {
  final List<String> moves; // simple strings like 'e2→e4', '[BOT] g8→f6'
  const MoveList({super.key, required this.moves});

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return const Center(child: Text('No moves yet'));
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, i) => Chip(label: Text(moves[i])),
      separatorBuilder: (context, i) => const SizedBox(width: 8),
      itemCount: moves.length,
    );
  }
}