import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// Events
abstract class AvatarEvent {}

class PickImageEvent extends AvatarEvent {}

class UploadImageEvent extends AvatarEvent {
  final File imageFile;
  UploadImageEvent(this.imageFile);
}

// States
abstract class AvatarState extends Equatable {
  const AvatarState();

  @override
  List<Object?> get props => [];
}

class AvatarInitial extends AvatarState {}

class AvatarPicking extends AvatarState {}

class AvatarCropping extends AvatarState {}

class AvatarUploading extends AvatarState {
  final double progress;
  const AvatarUploading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class AvatarUploaded extends AvatarState {
  final String downloadUrl;
  const AvatarUploaded(this.downloadUrl);

  @override
  List<Object?> get props => [downloadUrl];
}

class AvatarError extends AvatarState {
  final String message;
  const AvatarError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AvatarCubit extends Cubit<AvatarState> {
  final FirebaseStorage _storage;
  final ImagePicker _picker;
  final fb.FirebaseAuth _firebaseAuth;

  AvatarCubit({
    FirebaseStorage? storage,
    ImagePicker? picker,
    fb.FirebaseAuth? firebaseAuth,
  }) : _storage = storage ?? FirebaseStorage.instance,
       _picker = picker ?? ImagePicker(),
       _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       super(AvatarInitial());

  Future<void> pickImage() async {
    emit(AvatarPicking());
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        emit(AvatarInitial());
        return;
      }

      emit(AvatarCropping());
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (cropped == null) {
        emit(AvatarInitial());
        return;
      }

      final file = File(cropped.path);
      await uploadImage(file);
    } catch (e) {
      emit(AvatarError(e.toString()));
    }
  }

  Future<void> uploadImage(File imageFile) async {
    emit(const AvatarUploading(0));
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const AvatarError('User not authenticated'));
        return;
      }

      // Upload to Firebase Storage at avatars/{uid}/profile.jpg
      final fileName = 'avatars/${user.uid}/profile.jpg';
      final ref = _storage.ref().child(fileName);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        emit(AvatarUploading(progress));
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      emit(AvatarUploaded(downloadUrl));
    } catch (e) {
      emit(AvatarError(e.toString()));
    }
  }
}
