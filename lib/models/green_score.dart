import 'eco_action.dart';

class GreenScore {
  final double total;
  final double daily;
  final double weekly;

  GreenScore({required this.total, required this.daily, required this.weekly});

  static GreenScore fromActions(List<EcoAction> actions) {
    final now = DateTime.now();
    final today = actions.where(
      (a) =>
          a.timestamp.year == now.year &&
          a.timestamp.month == now.month &&
          a.timestamp.day == now.day,
    );
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek = actions.where((a) => a.timestamp.isAfter(weekAgo));
    return GreenScore(
      total: actions.fold(0, (sum, a) => sum + a.co2Saved),
      daily: today.fold(0, (sum, a) => sum + a.co2Saved),
      weekly: thisWeek.fold(0, (sum, a) => sum + a.co2Saved),
    );
  }
}
