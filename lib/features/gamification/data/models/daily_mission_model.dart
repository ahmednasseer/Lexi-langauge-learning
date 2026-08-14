import '../../domain/entities/daily_mission.dart';

class DailyMissionModel extends DailyMission {
  const DailyMissionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.target,
    super.currentProgress,
    required super.rewardXp,
    super.isCompleted,
    super.isClaimed,
    required super.date,
    super.icon,
  });

  factory DailyMissionModel.fromEntity(DailyMission mission) {
    return DailyMissionModel(
      id: mission.id,
      title: mission.title,
      description: mission.description,
      type: mission.type,
      target: mission.target,
      currentProgress: mission.currentProgress,
      rewardXp: mission.rewardXp,
      isCompleted: mission.isCompleted,
      isClaimed: mission.isClaimed,
      date: mission.date,
      icon: mission.icon,
    );
  }

  factory DailyMissionModel.fromJson(Map<String, dynamic> json) {
    return DailyMissionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: MissionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MissionType.completeLessons,
      ),
      target: json['target'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      rewardXp: json['rewardXp'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isClaimed: json['isClaimed'] ?? false,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'target': target,
      'currentProgress': currentProgress,
      'rewardXp': rewardXp,
      'isCompleted': isCompleted,
      'isClaimed': isClaimed,
      'date': date.toIso8601String(),
      'icon': icon,
    };
  }
}
