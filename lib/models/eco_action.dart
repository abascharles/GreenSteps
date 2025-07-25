class EcoAction {
  final String id;
  final String userId;
  final String actionType;
  final String category;
  final double co2Saved;
  final DateTime timestamp;

  EcoAction({
    required this.id,
    required this.userId,
    required this.actionType,
    required this.category,
    required this.co2Saved,
    required this.timestamp,
  });

  factory EcoAction.fromMap(Map<String, dynamic> map) {
    return EcoAction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      actionType: map['action_type'] as String,
      category: map['category'] as String,
      co2Saved: (map['co2_saved'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap({bool forInsert = false}) {
    final map = {
      'user_id': userId,
      'action_type': actionType,
      'category': category,
      'co2_saved': co2Saved,
      'timestamp': timestamp.toIso8601String(),
    };
    if (!forInsert && id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }
}
