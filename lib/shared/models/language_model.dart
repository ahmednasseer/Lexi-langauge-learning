class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isAvailable;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.isAvailable = true,
  });

  static const List<LanguageModel> all = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    LanguageModel(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    LanguageModel(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    LanguageModel(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    LanguageModel(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    LanguageModel(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    LanguageModel(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    LanguageModel(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    LanguageModel(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    LanguageModel(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
    LanguageModel(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
  ];
}
