import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'search_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final SearchRepository _searchRepo = SearchRepository();
  String _query = '';
  List<Map<String, String>> _remoteResults = [];
  bool _isSearching = false;

  final _words = [
    {
      'german': 'Hallo',
      'arabic': 'مرحباً',
      'example': 'Hallo, wie geht es dir?',
    },
    {'german': 'Danke', 'arabic': 'شكراً', 'example': 'Danke für deine Hilfe.'},
    {'german': 'Bitte', 'arabic': 'من فضلك', 'example': 'Bitte sehr.'},
    {
      'german': 'Guten Morgen',
      'arabic': 'صباح الخير',
      'example': 'Guten Morgen, Herr Müller!',
    },
    {
      'german': 'Entschuldigung',
      'arabic': 'عذراً',
      'example': 'Entschuldigung, wo ist der Bahnhof?',
    },
    {
      'german': 'Tschüss',
      'arabic': 'مع السلامة',
      'example': 'Tschüss, bis morgen!',
    },
    {'german': 'Ja', 'arabic': 'نعم', 'example': 'Ja, natürlich!'},
    {'german': 'Nein', 'arabic': 'لا', 'example': 'Nein, danke.'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) setState(() => _remoteResults = []);
      return;
    }
    if (mounted) setState(() => _isSearching = true);
    try {
      final results = await _searchRepo.search(query);
      if (mounted) {
        setState(() {
          _remoteResults = results
              .map(
                (r) => {
                  'german': r.title,
                  'arabic': r.subtitle ?? '',
                  'example': '',
                },
              )
              .toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'بحث',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1);
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          setState(() => _query = v);
          _runSearch(v);
        },
        style: GoogleFonts.poppins(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'ابحث عن الكلمات...',
          hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textHint),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: -0.05);
  }

  Widget _buildResults() {
    final localFiltered = _query.isEmpty
        ? _words
        : _words
              .where(
                (w) =>
                    (w['german'] as String).toLowerCase().contains(
                      _query.toLowerCase(),
                    ) ||
                    (w['arabic'] as String).contains(_query),
              )
              .toList();

    final remoteAsMap = _remoteResults;
    final merged = <Map<String, String>>[];
    if (_query.isNotEmpty && remoteAsMap.isNotEmpty) {
      merged.addAll(remoteAsMap);
      merged.addAll(localFiltered);
    } else {
      merged.addAll(localFiltered);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'الكلمات الألمانية',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        const SizedBox(height: 12),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : merged.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.textHint.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد نتائج',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: merged.length,
                  itemBuilder: (context, index) {
                    final item = merged[index];
                    return _buildWordCard(item, index);
                  },
                ),
        ),
        if (_query.isEmpty && _words.length > 5)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: _buildShowAllButton(),
            ),
          ),
      ],
    );
  }

  Widget _buildWordCard(Map<String, String> item, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    (item['german'] as String)[0],
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['german'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['arabic'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['example'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textHint,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + index * 60),
          duration: 400.ms,
        )
        .slideX(begin: 0.08);
  }

  Widget _buildShowAllButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/lessons'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'عرض كل الكلمات',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1);
  }
}
