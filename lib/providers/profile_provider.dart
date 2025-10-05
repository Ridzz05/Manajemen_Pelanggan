import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/business_profile.dart';
import '../utils/image_storage.dart';

class ProfileProvider extends ChangeNotifier {
  BusinessProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  BusinessProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper.instance;
      _profile = await dbHelper.getBusinessProfile();

      // If no profile exists, create default one
      if (_profile == null) {
        _profile = BusinessProfile.defaultProfile();
        await dbHelper.insertBusinessProfile(_profile!);
      }
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(BusinessProfile updatedProfile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper.instance;
      final rowsAffected = await dbHelper.updateBusinessProfile(updatedProfile);

      if (rowsAffected > 0) {
        _profile = updatedProfile;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfilePhoto(String imagePath) async {
    if (_profile == null) return false;

    try {
      final updatedProfile = _profile!.copyWith(
        businessLogo: imagePath,
        updatedAt: DateTime.now(),
      );

      return await updateProfile(updatedProfile);
    } catch (e) {
      _errorMessage = 'Error updating profile photo: $e';
      print(_errorMessage);
      return false;
    }
  }

  Future<String?> pickAndSaveImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final savedPath = await ImageStorage.saveProfileImage(
          File(pickedFile.path),
          'business_logo',
        );

        if (savedPath != null) {
          await updateProfilePhoto(savedPath);
          return savedPath;
        }
      }
      return null;
    } catch (e) {
      _errorMessage = 'Error picking image: $e';
      print(_errorMessage);
      return null;
    }
  }

  Future<bool> deleteProfilePhoto() async {
    if (_profile?.businessLogo.isEmpty ?? true) return false;

    try {
      // Delete from storage
      final deleted = await ImageStorage.deleteProfileImage(_profile!.businessLogo);

      if (deleted) {
        // Update profile to remove logo path
        final updatedProfile = _profile!.copyWith(
          businessLogo: '',
          updatedAt: DateTime.now(),
        );

        return await updateProfile(updatedProfile);
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error deleting profile photo: $e';
      print(_errorMessage);
      return false;
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
