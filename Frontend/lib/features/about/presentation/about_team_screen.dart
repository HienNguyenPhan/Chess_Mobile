import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutTeamScreen extends StatelessWidget {
  const AboutTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('about_team'.tr()),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Logo/Name
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.groups,
                      size: 80,
                      color: Color(0xFF1A237E),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dưa Chuột Team',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Team Members
              Text(
                'team_members'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildMemberTile(
                'Nguyễn Hoàng Tùng Dương',
                '21020182',
                Icons.person,
              ),
              _buildMemberTile(
                'Nguyễn Phan Hiển',
                '22022534',
                Icons.person,
              ),
              _buildMemberTile(
                'Nguyễn Hoài Thương',
                '22028323',
                Icons.person,
              ),
              _buildMemberTile(
                'Chu Thanh Quang',
                '20020703',
                Icons.person,
              ),
              
              const SizedBox(height: 32),
              
              // School Info
              Text(
                'school_info'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Trường Đại học Công nghệ - ĐHQGHN'),
                subtitle: const Text('University of Engineering and Technology - VNU'),
                dense: true,
              ),
              
              const SizedBox(height: 24),
              
              // Course Info
              Text(
                'course_info'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Phát triển ứng dụng di động'),
                subtitle: const Text('Mobile Application Development'),
                dense: true,
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('GV: TS. Nguyễn Đức Anh'),
                dense: true,
              ),
              
              const SizedBox(height: 32),
              
              // App Description
              Text(
                'app_info'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'app_description'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile(String name, String studentId, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      subtitle: Text('MSSV: $studentId'),
      dense: true,
    );
  }
}