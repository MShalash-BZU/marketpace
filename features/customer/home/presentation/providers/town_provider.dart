import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// نموذج بسيط للبلدة
class Town {
  final String id;
  final String name;
  Town({required this.id, required this.name});
  
  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(id: json['id'], name: json['name']);
  }
}

// 1. مزود لجلب قائمة البلدات من Supabase
final townsListProvider = FutureProvider<List<Town>>((ref) async {
  final response = await Supabase.instance.client
      .from('towns')
      .select('id, name')
      .eq('is_active', true);
      
  return (response as List).map((e) => Town.fromJson(e)).toList();
});

// 2. مزود للبلدة المختارة حالياً (StateNotifier)
class SelectedTownNotifier extends StateNotifier<Town?> {
  SelectedTownNotifier() : super(null) {
    _loadSavedTown();
  }

  Future<void> _loadSavedTown() async {
    final prefs = await SharedPreferences.getInstance();
    final townId = prefs.getString('selected_town_id');
    final townName = prefs.getString('selected_town_name');
    if (townId != null && townName != null) {
      state = Town(id: townId, name: townName);
    }
  }

  Future<void> setTown(Town town) async {
    state = town;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_town_id', town.id);
    await prefs.setString('selected_town_name', town.name);
  }
}

final selectedTownProvider = StateNotifierProvider<SelectedTownNotifier, Town?>((ref) {
  return SelectedTownNotifier();
});