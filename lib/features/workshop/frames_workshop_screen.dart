import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class _FrameItem {
  final int price;
  final Color color;
  final String label;
  final List<Color> gradientColors;
  final bool isOwned;

  const _FrameItem({
    required this.price,
    required this.color,
    required this.label,
    required this.gradientColors,
    this.isOwned = false,
  });
}

class FramesWorkshopScreen extends StatefulWidget {
  const FramesWorkshopScreen({super.key});

  @override
  State<FramesWorkshopScreen> createState() => _FramesWorkshopScreenState();
}

class _FramesWorkshopScreenState extends State<FramesWorkshopScreen> {
  int _selectedTabIndex = 0;
  int _selectedFrameIndex = -1;
  bool _showDetailSheet = false;
  bool _showPreviewSheet = false;

  final List<String> _tabTitles = [
    'لجميع الإطارات',
    'مميزة',
    'نادرة',
    'VIP',
  ];

  final List<_FrameItem> _allFrames = [
    const _FrameItem(
      price: 150,
      color: Color(0xFF8B5CF6),
      label: 'إطار أزرق',
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    const _FrameItem(
      price: 200,
      color: Color(0xFF22C55E),
      label: 'إطار أخضر',
      gradientColors: [Color(0xFF16A34A), Color(0xFF22C55E)],
    ),
    const _FrameItem(
      price: 250,
      color: Color(0xFFEC4899),
      label: 'إطار وردي',
      gradientColors: [Color(0xFFDB2777), Color(0xFFEC4899)],
    ),
    const _FrameItem(
      price: 300,
      color: Color(0xFF3B82F6),
      label: 'إطار سماوي',
      gradientColors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    ),
    const _FrameItem(
      price: 350,
      color: Color(0xFFFBBF24),
      label: 'إطار ذهبي',
      gradientColors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      isOwned: false,
    ),
    const _FrameItem(
      price: 400,
      color: Color(0xFFEF4444),
      label: 'إطار أحمر',
      gradientColors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    ),
    const _FrameItem(
      price: 500,
      color: Color(0xFF06B6D4),
      label: 'إطار مائي',
      gradientColors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
    ),
    const _FrameItem(
      price: 600,
      color: Color(0xFFF97316),
      label: 'إطار برتقالي',
      gradientColors: [Color(0xFFEA580C), Color(0xFFF97316)],
    ),
    const _FrameItem(
      price: 700,
      color: Color(0xFF8B5CF6),
      label: 'إطار ملكي',
      gradientColors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    ),
  ];

  List<_FrameItem> get _filteredFrames {
    switch (_selectedTabIndex) {
      case 0:
        return _allFrames;
      case 1:
        return _allFrames
            .where((f) => f.price >= 150 && f.price <= 300)
            .toList();
      case 2:
        return _allFrames
            .where((f) => f.price >= 300 && f.price <= 500)
            .toList();
      case 3:
        return _allFrames.where((f) => f.price >= 500).toList();
      default:
        return _allFrames;
    }
  }

  void _onFrameTap(int index) {
    setState(() {
      _selectedFrameIndex = index;
    });
    _showDetailSheet = true;
    _showPreviewSheet = false;
  }

  void _onBuyTap() {
    _showDetailSheet = false;
    _showPreviewSheet = true;
    setState(() {});
  }

  void _onApplyTap() {
    _showDetailSheet = false;
    _showPreviewSheet = false;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تطبيق الإطار بنجاح',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _closeSheets() {
    setState(() {
      _showDetailSheet = false;
      _showPreviewSheet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                const SizedBox(height: 20),
                Expanded(child: _buildFrameGrid()),
              ],
            ),
            if (_showDetailSheet) _buildDetailOverlay(),
            if (_showPreviewSheet) _buildPreviewOverlay(),
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
              'ورشة الإطارات',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.gemGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💎', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '1250',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(_tabTitles.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _tabTitles[index],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildFrameGrid() {
    final frames = _filteredFrames;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final frame = frames[index];
        return _buildFrameCard(frame, index);
      },
    );
  }

  Widget _buildFrameCard(_FrameItem frame, int index) {
    return GestureDetector(
      onTap: () => _onFrameTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: frame.color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ornate frame illustration
            SizedBox(
              width: 72,
              height: 72,
              child: CustomPaint(
                painter: _OrnateFramePainter(
                  color: frame.color,
                  gradientColors: frame.gradientColors,
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: frame.gradientColors
                            .map((c) => c.withValues(alpha: 0.3))
                            .toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Price badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.gemGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${frame.price}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text('💎', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 200 + index * 60),
          duration: 350.ms,
        )
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailOverlay() {
    final frame = _filteredFrames[_selectedFrameIndex];
    return GestureDetector(
      onTap: _closeSheets,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              offset: _showDetailSheet ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _showDetailSheet ? 1.0 : 0.0,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1117),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textHint,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'إختر إطارات',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Avatar with frame preview
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: frame.color.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              // Frame ring
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CustomPaint(
                                  painter: _OrnateFramePainter(
                                    color: frame.color,
                                    gradientColors: frame.gradientColors,
                                    strokeWidth: 4,
                                  ),
                                ),
                              ),
                              // Avatar circle
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      frame.color.withValues(alpha: 0.15),
                                      frame.color.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: frame.color.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Description
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      frame.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'إطار قاتح توقع لك في التعليم +10% نقاط',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Buy button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _onBuyTap,
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
                                    'شراء ${frame.price}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('💎', style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewOverlay() {
    final frame = _filteredFrames[_selectedFrameIndex];
    return GestureDetector(
      onTap: _closeSheets,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              offset: _showPreviewSheet ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _showPreviewSheet ? 1.0 : 0.0,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1117),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textHint,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'معاينة',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Avatar with frame applied
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: frame.color.withValues(alpha: 0.4),
                                      blurRadius: 40,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              // Frame ring
                              SizedBox(
                                width: 170,
                                height: 170,
                                child: CustomPaint(
                                  painter: _OrnateFramePainter(
                                    color: frame.color,
                                    gradientColors: frame.gradientColors,
                                    strokeWidth: 5,
                                    ornamentSize: 12,
                                  ),
                                ),
                              ),
                              // Avatar circle
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      frame.color.withValues(alpha: 0.2),
                                      frame.color.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: frame.color.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Info text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: frame.color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: frame.color,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'سيتم تطبيق الإطار على ملف الشخصي',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Apply button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _onApplyTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: frame.color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'تطبيق الإطار',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrnateFramePainter extends CustomPainter {
  final Color color;
  final List<Color> gradientColors;
  final double strokeWidth;
  final double ornamentSize;

  _OrnateFramePainter({
    required this.color,
    required this.gradientColors,
    this.strokeWidth = 3,
    this.ornamentSize = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    // Main ring gradient
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    // Inner ring
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.4);

    canvas.drawCircle(center, radius - strokeWidth - 3, innerPaint);

    // Outer ring
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.3);

    canvas.drawCircle(center, radius + 3, outerPaint);

    // Decorative dots around the frame
    final dotPaint = Paint()..style = PaintingStyle.fill;
    const numDots = 12;
    final dotRadius = ornamentSize / 2;

    for (int i = 0; i < numDots; i++) {
      final angle = (i * 2 * math.pi) / numDots;
      final dotCenter = Offset(
        center.dx + (radius + 6) * math.cos(angle),
        center.dy + (radius + 6) * math.sin(angle),
      );

      // Dot with gradient effect
      final dotGradient = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: 0.5),
        ],
      );

      dotPaint.shader = dotGradient.createShader(
        Rect.fromCircle(center: dotCenter, radius: dotRadius),
      );

      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }

    // Small ornamental arcs between dots
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: 0.5)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < numDots; i++) {
      final startAngle = (i * 2 * math.pi) / numDots + 0.15;
      final sweepAngle = (2 * math.pi) / numDots - 0.3;
      final arcRect = Rect.fromCircle(center: center, radius: radius + 12);
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
