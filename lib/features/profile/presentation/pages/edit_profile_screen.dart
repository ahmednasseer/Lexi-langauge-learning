import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/avatar_cubit.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<AvatarCubit>()),
      ],
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is ProfileLoaded) {
          _nameController.text = state.profile.name;
          _bioController.text = state.profile.bio ?? '';
        }

        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            actions: [
              TextButton(
                onPressed: isLoading ? null : _saveProfile,
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: BlocConsumer<AvatarCubit, AvatarState>(
                      listener: (context, avatarState) {
                        if (avatarState is AvatarUploaded) {
                          // Update profile with new avatar URL
                          final profileCubit = context.read<ProfileCubit>();
                          final currentProfile =
                              profileCubit.state is ProfileLoaded
                              ? (profileCubit.state as ProfileLoaded).profile
                              : null;
                          if (currentProfile != null) {
                            profileCubit.updateProfile(
                              currentProfile.copyWith(
                                photoUrl: avatarState.downloadUrl,
                              ),
                            );
                          }
                        }
                      },
                      builder: (context, avatarState) {
                        String? photoUrl;
                        if (avatarState is AvatarUploaded) {
                          photoUrl = avatarState.downloadUrl;
                        } else if (state is ProfileLoaded &&
                            state.profile.photoUrl != null) {
                          photoUrl = state.profile.photoUrl;
                        }

                        return Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.surface,
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.textHint,
                                        )
                                      : null,
                                ),
                                if (avatarState is AvatarUploading)
                                  const Positioned.fill(
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed:
                                  avatarState is AvatarPicking ||
                                      avatarState is AvatarCropping ||
                                      avatarState is AvatarUploading
                                  ? null
                                  : () =>
                                        context.read<AvatarCubit>().pickImage(),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Change Photo'),
                            ),
                            if (avatarState is AvatarError)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  avatarState.message,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel('Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter your name',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Bio'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _bioController,
                    hint: 'Tell us about yourself',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save Changes',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ProfileCubit>();
    final currentState = cubit.state;

    Profile currentProfile;
    if (currentState is ProfileLoaded) {
      currentProfile = currentState.profile;
    } else {
      return;
    }

    final updatedProfile = currentProfile.copyWith(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
    );

    await cubit.updateProfile(updatedProfile);
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.poppins(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
