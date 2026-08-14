import '../../core/services/api_service.dart';
import 'package:lexi/features/certificates/models/certificate.dart';

class CertificatesRepository {
  final ApiService _api = ApiService();
  Future<List<Certificate>> getCertificates() async {
    final result = await _api.getCertificates();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load certificates');
    }
    if (result.data == null) return [];
    return (result.data as List)
        .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> generateCertificate(String level) async {
    final result = await _api.generateCertificate(level);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to generate certificate');
    }
    return result.data as Map<String, dynamic>;
  }
}
