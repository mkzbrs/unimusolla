import '../core/network/api_client.dart';
import '../models/json_helpers.dart';
import '../models/musolla.dart';

class MusollaService {
  MusollaService(this._api);
  final ApiClient _api;

  Future<List<Musolla>> list() async {
    final data = await _api.get('/musollas/list.php');
    return unwrapList(data, [
      'musollas',
      'items',
      'data',
    ]).map((item) => Musolla.fromJson(asMap(item))).toList();
  }

  Future<List<Musolla>> search(String query) async {
    final data = await _api.get('/musollas/search.php', query: {'q': query});
    return unwrapList(data, [
      'musollas',
      'items',
      'data',
    ]).map((item) => Musolla.fromJson(asMap(item))).toList();
  }

  Future<Musolla> detail(int id) async {
    final data = await _api.get('/musollas/detail.php', query: {'id': id});
    return Musolla.fromJson(unwrapMap(data, ['musolla', 'data']));
  }
}
