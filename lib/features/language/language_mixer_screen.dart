import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class LanguageMixerScreen extends StatefulWidget {
  const LanguageMixerScreen({super.key});

  @override
  State<LanguageMixerScreen> createState() => _LanguageMixerScreenState();
}

class _LanguageMixerScreenState extends State<LanguageMixerScreen> {
  String _selectedLanguage = 'de';

  final _languages = [
    {'code': 'de', 'name': 'الألمانية', 'flag': '🇩🇪'},
    {'code': 'en', 'name': 'الإنجليزية', 'flag': '🇬🇧'},
    {'code': 'fr', 'name': 'الفرنسية', 'flag': '🇫🇷'},
    {'code': 'ja', 'name': 'اليابانية', 'flag': '🇯🇵'},
    {'code': 'es', 'name': 'الإسبانية', 'flag': '🇪🇸'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildLanguageLabel(),
            const SizedBox(height: 24),
            Expanded(child: _buildLanguageList()),
            const SizedBox(height: 24),
            _buildConfirmButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Icons.arrow_forward_ios,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'موزع اللغة',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  Widget _buildLanguageLabel() {
    return Text(
      'اختر لغتك',
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildLanguageList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(_languages.length, (index) {
          final lang = _languages[index];
          final code = lang['code'] as String;
          final name = lang['name'] as String;
          final flag = lang['flag'] as String;
          final isSelected = _selectedLanguage == code;

          return GestureDetector(
            onTap: () => setState(() => _selectedLanguage = code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Text(
                    flag,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textHint,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 300 + index * 80),
                duration: 350.ms,
              )
              .slideX(begin: 0.1);
        }),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final selectedLang =
        _languages.firstWhere((l) => l['code'] == _selectedLanguage);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم اختيار ${selectedLang['name']} ${selectedLang['flag']}',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'تأكيد اللغة ${selectedLang['flag']}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(begin: 0.15);
  }
}
