import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection_point.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CollectionPoint>> getCollectionPoints() async {
    final response = await _client.from('collection_points').select('*');
    return response.map((json) => CollectionPoint.fromMap(json)).toList();
  }
}