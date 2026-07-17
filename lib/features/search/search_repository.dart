import '../../services/api_service.dart';

class SearchResult {
  final String id;
  final String type;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    id: json['id'] ?? '',
    type: json['type'] ?? 'lesson',
    title: json['title'] ?? json['name'] ?? '',
    subtitle: json['subtitle'] ?? json['description'],
    imageUrl: json['imageUrl'],
  );
}

class SearchRepository {
  final ApiService _api = ApiService();

  Future<List<SearchResult>> search(String query, {String? type}) async {
    if (query.trim().isEmpty) return [];
    try {
      final result = await _api.search(query, type: type);
      if (result.isSuccess) {
        return result.data!
            .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
