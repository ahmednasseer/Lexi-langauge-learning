import 'package:flutter/material.dart';
import '../../shared/models/user_model.dart';
import '../../core/services/storage_service.dart';

class HomeController extends ChangeNotifier {
  UserModel _user = UserModel.empty();
  bool _isLoading = false;
  int _currentIndex = 0;

  UserModel get user => _user;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user =
          await StorageService.read<UserModel>('lexi_user_profile') ??
          UserModel.empty();
    } catch (e) {
      debugPrint('Error loading user: $e');
      _user = UserModel.empty();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setUser(UserModel user) {
    _user = user;
    StorageService.save('lexi_user_profile', user.toJson());
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
