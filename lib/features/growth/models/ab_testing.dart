enum ABTestStatus { draft, running, paused, completed }

enum ABTestVariant { a, b }

class ABTest {
  final String id;
  final String name;
  final String description;
  final ABTestStatus status;
  final List<ABTestVariantConfig> variants;
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, dynamic> targetMetric;
  final int minSampleSize;
  final Map<String, int> variantAssignments;

  const ABTest({
    required this.id,
    required this.name,
    required this.description,
    this.status = ABTestStatus.draft,
    required this.variants,
    required this.startDate,
    this.endDate,
    required this.targetMetric,
    this.minSampleSize = 1000,
    this.variantAssignments = const {},
  });

  ABTest copyWith({
    String? id,
    String? name,
    String? description,
    ABTestStatus? status,
    List<ABTestVariantConfig>? variants,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? targetMetric,
    int? minSampleSize,
    Map<String, int>? variantAssignments,
  }) {
    return ABTest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      variants: variants ?? this.variants,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetMetric: targetMetric ?? this.targetMetric,
      minSampleSize: minSampleSize ?? this.minSampleSize,
      variantAssignments: variantAssignments ?? this.variantAssignments,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status.name,
    'variants': variants.map((v) => v.toJson()).toList(),
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'targetMetric': targetMetric,
    'minSampleSize': minSampleSize,
    'variantAssignments': variantAssignments,
  };

  factory ABTest.fromJson(Map<String, dynamic> json) => ABTest(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    status: ABTestStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => ABTestStatus.draft,
    ),
    variants:
        (json['variants'] as List?)
            ?.map((v) => ABTestVariantConfig.fromJson(v))
            .toList() ??
        [],
    startDate: DateTime.parse(
      json['startDate'] ?? DateTime.now().toIso8601String(),
    ),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    targetMetric: Map<String, dynamic>.from(json['targetMetric'] ?? {}),
    minSampleSize: json['minSampleSize'] ?? 1000,
    variantAssignments: Map<String, int>.from(json['variantAssignments'] ?? {}),
  );

  factory ABTest.demo() => ABTest(
    id: 'ab_test_1',
    name: 'Home Screen Layout',
    description: 'Test which home screen layout increases engagement',
    status: ABTestStatus.running,
    variants: [
      const ABTestVariantConfig(
        id: 'variant_a',
        name: 'Goethe First',
        weight: 50,
        config: {'goethe_position': 'top'},
      ),
      const ABTestVariantConfig(
        id: 'variant_b',
        name: 'AI Coach First',
        weight: 50,
        config: {'ai_coach_position': 'top'},
      ),
    ],
    startDate: DateTime.now().subtract(const Duration(days: 7)),
    targetMetric: {'type': 'engagement', 'goal': 'increase_time'},
    minSampleSize: 500,
  );
}

class ABTestVariantConfig {
  final String id;
  final String name;
  final int weight;
  final Map<String, dynamic> config;

  const ABTestVariantConfig({
    required this.id,
    required this.name,
    required this.weight,
    required this.config,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'weight': weight,
    'config': config,
  };

  factory ABTestVariantConfig.fromJson(Map<String, dynamic> json) =>
      ABTestVariantConfig(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        weight: json['weight'] ?? 50,
        config: Map<String, dynamic>.from(json['config'] ?? {}),
      );
}

class ABTestResult {
  final String testId;
  final Map<String, ABTestVariantResult> variantResults;
  final String? winnerId;
  final double confidenceLevel;

  const ABTestResult({
    required this.testId,
    required this.variantResults,
    this.winnerId,
    this.confidenceLevel = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'testId': testId,
    'variantResults': variantResults.map((k, v) => MapEntry(k, v.toJson())),
    'winnerId': winnerId,
    'confidenceLevel': confidenceLevel,
  };

  factory ABTestResult.fromJson(Map<String, dynamic> json) => ABTestResult(
    testId: json['testId'] ?? '',
    variantResults:
        (json['variantResults'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, ABTestVariantResult.fromJson(v)),
        ) ??
        {},
    winnerId: json['winnerId'],
    confidenceLevel: (json['confidenceLevel'] ?? 0).toDouble(),
  );
}

class ABTestVariantResult {
  final String variantId;
  final int impressions;
  final int conversions;
  final double conversionRate;
  final double averageTime;

  const ABTestVariantResult({
    required this.variantId,
    required this.impressions,
    required this.conversions,
    required this.conversionRate,
    required this.averageTime,
  });

  Map<String, dynamic> toJson() => {
    'variantId': variantId,
    'impressions': impressions,
    'conversions': conversions,
    'conversionRate': conversionRate,
    'averageTime': averageTime,
  };

  factory ABTestVariantResult.fromJson(Map<String, dynamic> json) =>
      ABTestVariantResult(
        variantId: json['variantId'] ?? '',
        impressions: json['impressions'] ?? 0,
        conversions: json['conversions'] ?? 0,
        conversionRate: (json['conversionRate'] ?? 0).toDouble(),
        averageTime: (json['averageTime'] ?? 0).toDouble(),
      );
}
