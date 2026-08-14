import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AvatarEditorScreen extends StatefulWidget {
  const AvatarEditorScreen({super.key});

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  int _selectedTab = 0;
  int _selectedBody = 0;
  int _selectedEyes = 0;
  int _selectedHair = 0;
  int _selectedShirt = 0;
  int _selectedAccessory = 0;

  final List<String> _tabs = [
    'الجسم',
    'العيون',
    'الشعر',
    'القميص',
    'الإكسسوارات',
  ];

  final List<Color> _skinColors = [
    const Color(0xFFD4A574),
    const Color(0xFFF5C6A1),
    const Color(0xFFE8B88A),
    const Color(0xFFF0D5B8),
    const Color(0xFFC49A6C),
    const Color(0xFF8D6E4F),
    const Color(0xFFA07850),
    const Color(0xFFEDD1B8),
  ];

  final List<String> _eyeStyles = ['عادي', 'كبير', 'صغير', 'ناعم', 'سعيد'];
  final List<String> _hairStyles = ['قصير', 'طويل', 'مجعد', 'ذيل حصان', 'أصلع'];
  final List<String> _shirtStyles = [
    'تيشيرت',
    'بولو',
    'هودي',
    'بذلة',
    'قميص رياضي',
  ];
  final List<String> _accessories = ['قبعة', 'نظارات', 'قلادة', 'لا شيء'];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildAvatarPreview(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(child: _buildOptions()),
            const SizedBox(height: 12),
            _buildSaveButton(),
            const SizedBox(height: 16),
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
                Icons.close,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.3),
          const Spacer(),
          Text(
            'محرر الشخصية',
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

  Widget _buildAvatarPreview() {
    return AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.surface, AppColors.surfaceLight],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: _glowAnimation.value * 0.4,
                          ),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: AppColors.secondary.withValues(
                            alpha: _glowAnimation.value * 0.2,
                          ),
                          blurRadius: 60,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  _buildAvatarCharacter(),
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _tabs[_selectedTab],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 500.ms, delay: 200.ms);
  }

  Widget _buildAvatarCharacter() {
    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _skinColors[_selectedBody],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 22,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAvatarEye(),
                      const SizedBox(width: 18),
                      _buildAvatarEye(),
                    ],
                  ),
                ),
                Positioned(
                  top: 50,
                  child: Container(
                    width: 16,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(top: 0, child: _buildHairOverlay()),
          Positioned(bottom: 0, child: _buildShirtOverlay()),
          if (_selectedAccessory > 0 &&
              _selectedAccessory < _accessories.length)
            Positioned(
              top: _selectedAccessory == 1 ? -4 : 30,
              child: _buildAccessoryOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarEye() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildHairOverlay() {
    final hairColors = [
      const Color(0xFF2C1810),
      const Color(0xFF4A3228),
      const Color(0xFF8B6914),
      const Color(0xFF1A1A2E),
      Colors.transparent,
    ];
    final hairColor = hairColors[_selectedHair.clamp(0, hairColors.length - 1)];

    if (_selectedHair == 4) return const SizedBox.shrink();

    return Container(
      width: 90,
      height: 45,
      decoration: BoxDecoration(
        color: hairColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
        ),
      ),
    );
  }

  Widget _buildShirtOverlay() {
    final shirtColors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.gold,
      AppColors.accent,
    ];
    final shirtColor =
        shirtColors[_selectedShirt.clamp(0, shirtColors.length - 1)];

    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        color: shirtColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    );
  }

  Widget _buildAccessoryOverlay() {
    switch (_selectedAccessory) {
      case 1:
        return Container(
          width: 86,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gold, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case 2:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 26),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          ],
        );
      case 3:
        return Container(
          width: 4,
          height: 30,
          margin: const EdgeInsets.only(left: 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold, AppColors.goldDark],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _tabs[index],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildOptions() {
    switch (_selectedTab) {
      case 0:
        return _buildSkinColorGrid();
      case 1:
        return _buildStyleGrid(
          _eyeStyles,
          _selectedEyes,
          (i) => setState(() => _selectedEyes = i),
        );
      case 2:
        return _buildStyleGrid(
          _hairStyles,
          _selectedHair,
          (i) => setState(() => _selectedHair = i),
        );
      case 3:
        return _buildStyleGrid(
          _shirtStyles,
          _selectedShirt,
          (i) => setState(() => _selectedShirt = i),
        );
      case 4:
        return _buildAccessoryGrid();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSkinColorGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لون البشرة',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemCount: _skinColors.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedBody == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBody = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _skinColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : AppColors.border,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  ),
                ).animate().fadeIn(
                  duration: 300.ms,
                  delay: Duration(milliseconds: 50 * index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleGrid(
    List<String> options,
    int selected,
    Function(int) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tabs[_selectedTab],
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final isSelected = selected == index;
                return GestureDetector(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 14,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTabIcon(_selectedTab, index),
                            size: 28,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            options[index],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(
                  duration: 300.ms,
                  delay: Duration(milliseconds: 60 * index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessoryGrid() {
    final accessoryIcons = [
      Icons.checkroom,
      Icons.visibility,
      Icons.diamond,
      Icons.block,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإكسسوارات',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _accessories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedAccessory == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAccessory = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 14,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            accessoryIcons[index],
                            size: 28,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _accessories[index],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(
                  duration: 300.ms,
                  delay: Duration(milliseconds: 60 * index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTabIcon(int tabIndex, int optionIndex) {
    switch (tabIndex) {
      case 1:
        final eyeIcons = [
          Icons.remove_red_eye,
          Icons.visibility,
          Icons.visibility_off,
          Icons.nightlight_round,
          Icons.sentiment_satisfied,
        ];
        return eyeIcons[optionIndex.clamp(0, eyeIcons.length - 1)];
      case 2:
        final hairIcons = [
          Icons.content_cut,
          Icons.face,
          Icons.waves,
          Icons.sports_gymnastics,
          Icons.block,
        ];
        return hairIcons[optionIndex.clamp(0, hairIcons.length - 1)];
      case 3:
        final shirtIcons = [
          Icons.checkroom,
          Icons.dry_cleaning,
          Icons.ac_unit,
          Icons.business_center,
          Icons.sports_motorsports,
        ];
        return shirtIcons[optionIndex.clamp(0, shirtIcons.length - 1)];
      default:
        return Icons.circle;
    }
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
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
              'حفظ',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.3),
    );
  }
}
