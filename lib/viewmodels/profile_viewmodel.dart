import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  UserProfile? profile;

  ProfileViewModel() {
    loadProfile();
  }

  void loadProfile() {
    final box = Hive.box<UserProfile>('user_profile');
    if (box.isNotEmpty) {
      profile = box.getAt(0);
    }
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    final box = Hive.box<UserProfile>('user_profile');
    if (box.isEmpty) {
      await box.add(newProfile);
    } else {
      await box.putAt(0, newProfile);
    }
    profile = newProfile;
    notifyListeners();
  }

  bool get hasProfile => profile != null;
}
