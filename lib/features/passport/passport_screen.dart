import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  int _selectedIndex = 0;

  final List<_LanguageOption> _languages = [
    _LanguageOption(
      name: 'الألمانية',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
    ),
    _LanguageOption(
      name: 'الإنجليزية',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    _LanguageOption(
      name: 'الفرنسية',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
    _LanguageOption(
      name: 'اليابانية',
      nativeName: '日本語',
      flag: '🇯🇵',
    ),
    _LanguageOption(
      name: 'الإسبانية',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildSubtitle(),
            const SizedBox(height: 24),
            Expanded(child: _buildLanguageList()),
            const SizedBox(height: 16),
            _buildConfirmButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.3),
          const Spacer(),
          Text(
            'جواز اللغة',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'اختر لغتك',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            'يمكنك تغيير لغتك في أي وقت',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildLanguageList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final language = _languages[index];
        final isSelected = _selectedIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLanguageTile(language, isSelected, index),
        );
      },
    );
  }

  Widget _buildLanguageTile(_LanguageOption language, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: -3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    language.nativeName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 150 * index))
          .slideX(begin: 0.15, curve: Curves.easeOut),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context, _languages[_selectedIndex]);
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'تأكيد',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 500.ms, delay: 500.ms)
          .slideY(begin: 0.3),
    );
  }
}

class _LanguageOption {
  final String name;
  final String nativeName;
  final String flag;

  const _LanguageOption({
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
