import 'package:chess_app/core/routes/route_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image hoặc Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo hoặc Icon
                Icon(
                  Icons.sports_esports,
                  size: 120,
                  color: Colors.white.withOpacity(0.9),
                ),
                
                const SizedBox(height: 24),
                
                // Tiêu đề
                Text(
                  'app_name'.tr(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Mô tả
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'app_description'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Nút bắt đầu
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: ElevatedButton(
                    onPressed: () {
                      try {
                        print('Debug - Navigation - Using path: ${RouteConstants.signin}');
                        print('Debug - Navigation - Using name: ${RouteConstants.signin}');
                        
                        // Sử dụng path thay vì name
                        context.go(RouteConstants.signin);
                      } catch (e) {
                        print('Navigation error: $e');
                        print('Error details: ${e.toString()}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Navigation failed: ${e.toString()}')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'get_started'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}