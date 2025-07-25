import 'package:flutter/material.dart';
import '../models/eco_action.dart';
import '../models/green_score.dart';
import '../services/eco_action_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'log_action_screen.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final EcoActionService _ecoActionService = EcoActionService();
  List<EcoAction> _actions = [];
  GreenScore? _score;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchActions();
  }

  Future<void> _fetchActions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Not signed in.';
          _isLoading = false;
        });
        return;
      }
      final actions = await _ecoActionService.getActionsForUser(user.id);
      setState(() {
        _actions = actions;
        _score = GreenScore.fromActions(actions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onLogActionPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogActionScreen()),
    );
    if (result == true) {
      _fetchActions();
    }
  }

  List<BarChartGroupData> _buildBarChartData() {
    final now = DateTime.now();
    List<double> dailyTotals = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayActions = _actions.where(
        (a) =>
            a.timestamp.year == day.year &&
            a.timestamp.month == day.month &&
            a.timestamp.day == day.day,
      );
      return dayActions.fold(0.0, (sum, a) => sum + a.co2Saved);
    });
    return List.generate(
      7,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: dailyTotals[i], color: Colors.green, width: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = AppTheme.primaryGreen;
    final Color accentGreen = AppTheme.accentGreen;
    final double borderRadius = AppTheme.borderRadius;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'GreenSteps',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : RefreshIndicator(
              onRefresh: _fetchActions,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // Green Score Circular Progress
                  Container(
                    decoration: BoxDecoration(
                      color: mainGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: (_score?.total ?? 0) / 100,
                                strokeWidth: 12,
                                backgroundColor: mainGreen.withOpacity(0.18),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accentGreen,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Green',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    color: accentGreen,
                                  ),
                                ),
                                Text(
                                  'Score',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    color: accentGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _score?.total.toStringAsFixed(1) ?? '0',
                                  style: GoogleFonts.nunito(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: accentGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quick Actions (example, can be dynamic)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickActionCard(
                        icon: Icons.directions_bike,
                        label: 'Bike to work',
                        color: accentGreen,
                      ),
                      _QuickActionCard(
                        icon: Icons.recycling,
                        label: 'Recycle',
                        color: mainGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bar Chart
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: mainGreen.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (_actions.isEmpty
                            ? 5
                            : _actions
                                      .map((a) => a.co2Saved)
                                      .reduce((a, b) => a > b ? a : b) +
                                  2),
                        barGroups: _buildBarChartData(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(0),
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: accentGreen,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final now = DateTime.now();
                                final day = now.subtract(
                                  Duration(days: 6 - value.toInt()),
                                );
                                return Text(
                                  '${day.month}/${day.day}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 10,
                                    color: accentGreen,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Actions',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_actions.isEmpty)
                    Text('No actions logged yet.', style: GoogleFonts.nunito()),
                  ..._actions
                      .take(10)
                      .map(
                        (action) => Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle_rounded,
                              color: accentGreen,
                            ),
                            title: Text(
                              action.actionType,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${action.category} • ${action.timestamp.toLocal().toString().split(".")[0]}',
                              style: GoogleFonts.nunito(),
                            ),
                            trailing: Text(
                              '+${action.co2Saved.toStringAsFixed(2)} kg',
                              style: GoogleFonts.nunito(
                                color: accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _onLogActionPressed,
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Log Eco Action',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _ModernBottomNav(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(icon: Icons.home_rounded, route: '/dashboard'),
          _NavIcon(icon: Icons.add_circle_outline_rounded, route: '/log'),
          _NavIcon(icon: Icons.leaderboard_rounded, route: '/leaderboard'),
          _NavIcon(icon: Icons.account_circle_rounded, route: '/profile'),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String route;
  const _NavIcon({required this.icon, required this.route});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 30, color: AppTheme.accentGreen),
      onPressed: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
