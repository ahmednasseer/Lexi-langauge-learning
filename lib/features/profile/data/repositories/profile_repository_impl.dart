import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _firebaseAuth;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  @override
  Future<Profile?> getCurrentProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return getProfile(user.uid);
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ProfileModel.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final model = ProfileModel(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        photoUrl: profile.photoUrl,
        bio: profile.bio,
        nativeLanguage: profile.nativeLanguage,
        learningLanguage: profile.learningLanguage,
        isPremium: profile.isPremium,
        xp: profile.xp,
        level: profile.level,
        streak: profile.streak,
        dailyGoal: profile.dailyGoal,
        notificationsEnabled: profile.notificationsEnabled,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(profile.id).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete profile');
    }
  }

  @override
  Future<void> updatePreferences({
    bool? notificationsEnabled,
    int? dailyGoal,
    String? learningLanguage,
    String? nativeLanguage,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (notificationsEnabled != null) {
      updates['notificationsEnabled'] = notificationsEnabled;
    }
    if (dailyGoal != null) updates['dailyGoal'] = dailyGoal;
    if (learningLanguage != null) updates['learningLanguage'] = learningLanguage;
    if (nativeLanguage != null) updates['nativeLanguage'] = nativeLanguage;

    try {
      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update preferences');
    }
  }
}
