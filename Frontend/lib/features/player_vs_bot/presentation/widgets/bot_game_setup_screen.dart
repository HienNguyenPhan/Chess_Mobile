import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chess_app/core/routes/route_constants.dart';

class BotGameSetupScreen extends StatefulWidget {
  const BotGameSetupScreen({super.key});

  @override
  State<BotGameSetupScreen> createState() => _BotGameSetupScreenState();
}

class _BotGameSetupScreenState extends State<BotGameSetupScreen> {
  int _selectedMinutes = 5;
  String _selectedColor = 'white';
  String _selectedDifficulty = 'medium'; // 👈 Thêm biến độ khó mặc định

  final _timeOptions = [3, 5, 10, 15, 30];
  final _difficultyOptions = [
    {'key': 'easy', 'label': 'Dễ'},
    {'key': 'medium', 'label': 'Trung bình'},
    {'key': 'hard', 'label': 'Khó'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt ván đấu'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⏱️ Chọn thời gian
            const Text(
              '⏱️ Chọn thời gian mỗi bên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _timeOptions.map((min) {
                final isSelected = _selectedMinutes == min;
                return ChoiceChip(
                  label: Text('$min phút'),
                  selected: isSelected,
                  selectedColor: const Color(0xFF7C4DFF),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _selectedMinutes = min),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // ♟️ Chọn màu quân
            const Text(
              '♟️ Chọn màu quân của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedColor = 'white'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedColor == 'white'
                              ? const Color(0xFF7C4DFF)
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.circle,
                              size: 32,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 1,
                                    color: Colors.black)
                              ]),
                          SizedBox(height: 8),
                          Text('Quân Trắng',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedColor = 'black'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedColor == 'black'
                              ? const Color(0xFF7C4DFF)
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.circle, size: 32, color: Colors.black),
                          SizedBox(height: 8),
                          Text(
                            'Quân Đen',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 🎯 Chọn độ khó
            const Text(
              '🎯 Chọn độ khó',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _difficultyOptions.map((option) {
                final isSelected = _selectedDifficulty == option['key'];
                return ChoiceChip(
                  label: Text(option['label']!),
                  selected: isSelected,
                  selectedColor: const Color(0xFF7C4DFF),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedDifficulty = option['key']!),
                );
              }).toList(),
            ),

            const Spacer(),

            // ▶️ Nút bắt đầu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Bắt đầu chơi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.push(
                    RouteConstants.singlePlayer,
                    extra: {
                      'minutes': _selectedMinutes,
                      'color': _selectedColor,
                      'difficulty': _selectedDifficulty, // 👈 gửi theo độ khó
                    },
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
