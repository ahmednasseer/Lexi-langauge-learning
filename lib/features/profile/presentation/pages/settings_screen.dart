import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/auth/presentation/bloc/auth_cubit.dart';
import '../bloc/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is SettingsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SettingsError) {
          return Center(
            child: Text(
              state.message,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }

        final settings = state is SettingsLoaded
            ? state
            : const SettingsLoaded(
                darkMode: false,
                notificationsEnabled: true,
                learningLanguage: 'German',
                dailyGoal: 50,
              );

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E21),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1E36),
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _section('Appearance', [
                _switchTile(
                  Icons.dark_mode,
                  'Dark Mode',
                  settings.darkMode,
                  (v) => context.read<SettingsCubit>().toggleDarkMode(),
                ),
              ]),
              const SizedBox(height: 16),
              _section('Learning', [
                _dropdownTile(
                  Icons.language,
                  'Learning Language',
                  settings.learningLanguage,
                  ['English', 'Arabic', 'French', 'Spanish', 'German'],
                  (v) => context.read<SettingsCubit>().setLearningLanguage(v!),
                ),
                _sliderTile(
                  Icons.track_changes,
                  'Daily Goal',
                  settings.dailyGoal,
                  (v) => context.read<SettingsCubit>().setDailyGoal(v.toInt()),
                ),
              ]),
              const SizedBox(height: 16),
              _section('Notifications', [
                _switchTile(
                  Icons.notifications,
                  'Push Notifications',
                  settings.notificationsEnabled,
                  (v) => context.read<SettingsCubit>().toggleNotifications(),
                ),
              ]),
              const SizedBox(height: 16),
              _section('Account', [
                _navTile(Icons.person, 'Edit Profile', () {
                  Navigator.pushNamed(context, '/profile-edit');
                }),
                _navTile(Icons.lock, 'Change Password', () {}),
                _navTile(Icons.logout, 'Logout', () async {
                  final navigator = Navigator.of(context);
                  await context.read<AuthCubit>().signOut();
                  navigator.pushNamedAndRemoveUntil('/auth', (route) => false);
                }),
                _navTile(
                  Icons.delete,
                  'Delete Account',
                  () {},
                  color: AppColors.error,
                ),
              ]),
              const SizedBox(height: 16),
              _section('Support', [
                _navTile(Icons.help, 'Help Center', () {}),
                _navTile(Icons.email, 'Contact Us', () {}),
                _navTile(Icons.description, 'Terms of Service', () {}),
                _navTile(Icons.privacy_tip, 'Privacy Policy', () {}),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E36),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _switchTile(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _dropdownTile(
    IconData icon,
    String title,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1A1E36),
        items: items
            .map(
              (i) => DropdownMenuItem(
                value: i,
                child: Text(i, style: const TextStyle(color: Colors.white)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _sliderTile(
    IconData icon,
    String title,
    int value,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        '$title: $value XP',
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
      ),
      trailing: SizedBox(
        width: 150,
        child: Slider(
          value: value.toDouble(),
          min: 10,
          max: 200,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _navTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, color: color ?? Colors.white),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: color ?? Colors.white54,
      ),
      onTap: onTap,
    );
  }
}
