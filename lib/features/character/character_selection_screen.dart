import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  String? _selectedCharacter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildCharacterGrid(),
              const SizedBox(height: 32),
              _buildSelectButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'اختيار شخصية Lexi',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildCharacterGrid() {
    final characters = [
      _CharacterData(
        name: 'Lena',
        emoji: '👧',
        hairColor: AppColors.gold,
        description: 'فتاة بشعر أشقر',
        bgGradient: const [Color(0xFFEC4899), Color(0xFFDB2777)],
      ),
      _CharacterData(
        name: 'Paul',
        emoji: '👦',
        hairColor: const Color(0xFF8B4513),
        description: 'ولد بشعر بني',
        bgGradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
      ),
      _CharacterData(
        name: 'Anna',
        emoji: '👧',
        hairColor: const Color(0xFFDC2626),
        description: 'فتاة بشعر أحمر',
        bgGradient: const [Color(0xFF22C55E), Color(0xFF16A34A)],
      ),
      _CharacterData(
        name: 'Max',
        emoji: '👦',
        hairColor: const Color(0xFF1F2937),
        description: 'ولد بشعر أسود',
        bgGradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        final isSelected = _selectedCharacter == character.name;
        return _buildCharacterCard(character, isSelected, index);
      },
    );
  }

  Widget _buildCharacterCard(_CharacterData character, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCharacter = character.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: character.bgGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? character.bgGradient.first : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: character.bgGradient.first.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    character.bgGradient.first.withValues(alpha: 0.3),
                    character.bgGradient.last.withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: isSelected ? Colors.white.withValues(alpha: 0.5) : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  character.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              character.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              character.description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              const Icon(Icons.check_circle, color: Colors.white, size: 22),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 200 + index * 100)).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSelectButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedCharacter == null
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم اختيار $_selectedCharacter!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'اختر شخصية Lexi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _selectedCharacter == null ? AppColors.textHint : Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }
}

class _CharacterData {
  final String name;
  final String emoji;
  final Color hairColor;
  final String description;
  final List<Color> bgGradient;

  const _CharacterData({
    required this.name,
    required this.emoji,
    required this.hairColor,
    required this.description,
    required this.bgGradient,
  });
}
