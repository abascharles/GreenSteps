import 'package:flutter/material.dart';
import '../services/eco_action_service.dart';
import '../models/eco_action.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LogActionScreen extends StatefulWidget {
  const LogActionScreen({super.key});

  @override
  State<LogActionScreen> createState() => _LogActionScreenState();
}

class _LogActionScreenState extends State<LogActionScreen> {
  final _ecoActionService = EcoActionService();
  final _co2Controller = TextEditingController();
  String? _selectedCategory;
  String? _selectedAction;
  bool _isLoading = false;
  String? _error;

  final Map<String, List<String>> _actionsByCategory = {
    'Transport': ['Biked to work', 'Used public transport', 'Carpooled'],
    'Waste': ['No plastic use', 'Recycled waste'],
    'Nature': ['Planted a tree', 'Gardened'],
    'Energy': ['Used LED bulbs', 'Turned off lights'],
  };

  // Stub: In a real app, fetch from Supabase lookup_actions
  double _estimateCO2(String? category, String? action) {
    if (category == 'Transport' && action == 'Biked to work') return 2.5;
    if (category == 'Transport' && action == 'Used public transport') {
      return 1.2;
    }
    if (category == 'Waste' && action == 'No plastic use') return 0.5;
    if (category == 'Nature' && action == 'Planted a tree') return 21.0;
    return 1.0;
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _selectedCategory = value;
      _selectedAction = null;
      _co2Controller.text = '';
    });
  }

  void _onActionChanged(String? value) {
    setState(() {
      _selectedAction = value;
      _co2Controller.text = value != null
          ? _estimateCO2(_selectedCategory, value).toString()
          : '';
    });
  }

  void _onSave() async {
    if (_selectedCategory == null ||
        _selectedAction == null ||
        _co2Controller.text.isEmpty) {
      setState(() {
        _error = 'Please fill all fields.';
      });
      return;
    }
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
      final action = EcoAction(
        id: '', // Supabase will auto-generate
        userId: user.id,
        actionType: _selectedAction!,
        category: _selectedCategory!,
        co2Saved: double.tryParse(_co2Controller.text) ?? 0.0,
        timestamp: DateTime.now(),
      );
      await _ecoActionService.logAction(action, forInsert: true);
      if (!mounted) return;
      Navigator.pop(context, true); // Indicate success
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log action: $_error')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          'Log Eco Action',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Log Eco Action',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: accentGreen,
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _actionsByCategory.keys
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: GoogleFonts.nunito()),
                        ),
                      )
                      .toList(),
                  onChanged: _onCategoryChanged,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAction,
                  items:
                      (_selectedCategory != null
                              ? _actionsByCategory[_selectedCategory!]
                              : [])
                          ?.map(
                            (act) => DropdownMenuItem<String>(
                              value: act,
                              child: Text(act, style: GoogleFonts.nunito()),
                            ),
                          )
                          .toList()
                          .cast<DropdownMenuItem<String>>(),
                  onChanged: _onActionChanged,
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    prefixIcon: Icon(Icons.eco_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _co2Controller,
                  decoration: const InputDecoration(
                    labelText: 'CO₂ Saved (kg)',
                    prefixIcon: Icon(Icons.cloud_done_rounded),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: GoogleFonts.nunito(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
