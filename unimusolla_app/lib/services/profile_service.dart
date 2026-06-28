import 'package:image_picker/image_picker.dart';

import '../core/network/api_client.dart';
import '../models/json_helpers.dart';
import '../models/user.dart';

class ProfileService {
  ProfileService(this._api);
  final ApiClient _api;

  Future<User> me(int userId) async {
    final data = await _api.get('/profile/me.php', query: {'id': userId});
    return User.fromJson(unwrapMap(data, ['user', 'data']));
  }

  Future<User> update(int userId, String username, XFile? image) async {
    await _api.post(
      '/profile/update.php',
      data: {'id': userId, 'username': username},
    );
    if (image != null) {
      await _api.upload(
        '/uploads/profile.php',
        files: [image],
        field: 'image',
        arrayField: false,
        data: {'user_id': userId},
      );
    }
    return me(userId);
  }
}
