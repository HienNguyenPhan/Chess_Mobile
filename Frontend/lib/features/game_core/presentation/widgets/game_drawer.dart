import 'package:chess_app/core/routes/route_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GameDrawer extends StatelessWidget {
  const GameDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F6C5A), Color(0xFF00BFA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF2F6C5A)),
              ),
              accountName: Text(
                user?.displayName ?? 'player'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? 'no_email'.tr()),
            ),

            // --- Menu Items ---
            _DrawerTile(
              icon: Icons.person_outline,
              title: 'profile'.tr(),
              onTap: () {
                Navigator.pop(context);
                context.push(RouteConstants.profile);
              },
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              title: 'settings'.tr(),
              onTap: () {
                Navigator.pop(context);
                context.push(RouteConstants.setting);
              },
            ),
            _DrawerTile(
              icon: Icons.info_outline,
              title: 'about'.tr(),
              onTap: () {
                Navigator.pop(context);
                context.push(RouteConstants.about);
              },
            ),
            _DrawerTile(
              icon: Icons.emoji_events_outlined,
              title: 'Bảng xếp hạng',
              onTap: () {
                Navigator.pop(context);
                context.push(RouteConstants.leaderboard);
              },
            ),

            const Spacer(),

            // --- Language Switch ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.language, color: Colors.black87),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    context.locale.languageCode == 'vi'
                        ? 'English 🇺🇸'
                        : 'Tiếng Việt 🇻🇳',
                    key: ValueKey(context.locale.languageCode),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.grey.shade100,
                ),
                onPressed: () async {
                  final newLocale = context.locale.languageCode == 'vi'
                      ? const Locale('en')
                      : const Locale('vi');
                  await context.setLocale(newLocale);
                },
              ),
            ),

            // Version Info
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'v${snapshot.data?.version ?? '1.0.0'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // --- Logout ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text('logout'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go(RouteConstants.signin);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      onTap: onTap,
    );
  }
}
