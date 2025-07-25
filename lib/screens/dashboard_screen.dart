import 'package:flutter/material.dart';
import '../models/eco_action.dart';
import '../models/green_score.dart';
import '../services/eco_action_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'log_action_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenSteps Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Leaderboard',
            onPressed: () {
              Navigator.pushNamed(context, '/leaderboard');
            },
          ),
        ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Green Score:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _score?.total.toStringAsFixed(1) ?? '0',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: Colors.green[700]),
                      ),
                      const Icon(Icons.eco, color: Colors.green, size: 32),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress chart
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[900] ?? Colors.black,
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
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[900] ?? Colors.black,
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_actions.isEmpty) const Text('No actions logged yet.'),
                  ..._actions
                      .take(10)
                      .map(
                        (action) => Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text(action.actionType),
                            subtitle: Text(
                              '${action.category} • ${action.timestamp.toLocal().toString().split(".")[0]}',
                            ),
                            trailing: Text(
                              '+${action.co2Saved.toStringAsFixed(2)} kg',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _onLogActionPressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Log Eco Action'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
