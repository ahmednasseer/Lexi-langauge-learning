import '../../core/services/api_service.dart';
import 'models/certificate.dart';

class CertificatesRepository {
  final ApiService _api = ApiService();

  Future<List<Certificate>> getCertificates() async {
    try {
      final result = await _api.getCertificates();
      if (result.isSuccess && result.data != null) {
        return (result.data as List)
            .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> generateCertificate(String level) async {
    try {
      final result = await _api.generateCertificate(level);
      if (result.isSuccess && result.data != null) {
        return result.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
