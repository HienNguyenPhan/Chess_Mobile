import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = [
      {'name': 'Nguyễn Văn A', 'score': 2450},
      {'name': 'Trần Thị B', 'score': 2200},
      {'name': 'Lê Hoàng C', 'score': 2100},
      {'name': 'Phạm Minh D', 'score': 1980},
      {'name': 'Võ Anh E', 'score': 1800},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Bảng xếp hạng'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tiêu đề
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 1, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Người chơi', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Điểm', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Danh sách người chơi
            Expanded(
              child: ListView.separated(
                itemCount: players.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final player = players[index];
                  final rank = index + 1;
                  final color = rank == 1
                      ? Colors.amber
                      : rank == 2
                          ? Colors.grey
                          : rank == 3
                              ? const Color(0xFFCD7F32)
                              : Colors.black54;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      player['score'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
