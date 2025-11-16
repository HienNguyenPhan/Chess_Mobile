import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final bool isBotThinking;
  final String turnText;
  const StatusBar({super.key, required this.isBotThinking, required this.turnText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(isBotThinking ? Icons.smart_toy : Icons.person, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBotThinking ? 'Bot is thinking…' : turnText,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isBotThinking) const SizedBox(width: 8),
          if (isBotThinking) const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}