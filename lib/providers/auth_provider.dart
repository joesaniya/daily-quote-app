import 'package:flutter/foundation.dart';
import 'package:sample_app/config/supa_base_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _emailConfirmationRequired = false;

  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get emailConfirmationRequired => _emailConfirmationRequired;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Listen to auth state changes
    SupabaseConfig.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _currentUser = session.user;
        await _loadUserProfile();
        notifyListeners();
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _userProfile = null;
        notifyListeners();
      }
    });

    // Check if there's an existing session
    final session = SupabaseConfig.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
      await _loadUserProfile();
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      final response = await SupabaseConfig.userProfiles
          .select()
          .eq('id', _currentUser!.id)
          .single();

      _userProfile = UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Profile might not exist yet, create one
      await _createUserProfile();
    }
  }

  Future<void> _createUserProfile() async {
    if (_currentUser == null) return;

    try {
      final profile = UserProfile(
        id: _currentUser!.id,
        displayName: _currentUser!.email ?? 'User',
      );

      await SupabaseConfig.userProfiles.insert(profile.toJson());
      _userProfile = profile;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    _emailConfirmationRequired = false;
    notifyListeners();

    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName ?? email},
      );

      if (response.user != null) {
        // Check if email confirmation is required
        if (response.session == null) {
          _emailConfirmationRequired = true;
          _error = 'Please check your email to confirm your account';
          return false;
        }

        _currentUser = response.user;
        await _loadUserProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Sign up failed';
      return false;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('email') &&
          e.message.toLowerCase().contains('confirm')) {
        _emailConfirmationRequired = true;
        _error = 'Please check your email to confirm your account';
      } else {
        _error = e.message;
      }
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    _emailConfirmationRequired = false;
    notifyListeners();

    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Sign in failed';
      return false;
    } on AuthException catch (e) {
      // Check if the error is about email confirmation
      if (e.message.toLowerCase().contains('email') &&
          e.message.toLowerCase().contains('confirm')) {
        _emailConfirmationRequired = true;
        _error =
            'Please verify your email address before signing in. Check your inbox for the confirmation link.';
      } else {
        _error = e.message;
      }
      debugPrint('Sign in auth error: ${e.message}');
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resend confirmation email
  Future<bool> resendConfirmationEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseConfig.auth.resend(type: OtpType.signup, email: email);
      _error = 'Confirmation email sent! Please check your inbox.';
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to resend confirmation email';
      debugPrint('Resend confirmation error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
      _currentUser = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to send reset email';
      debugPrint('Password reset error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserProfile profile) async {
    if (_currentUser == null) return false;

    try {
      await SupabaseConfig.userProfiles
          .update(profile.toJson())
          .eq('id', _currentUser!.id);

      _userProfile = profile;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // Update display name
  Future<bool> updateDisplayName(String displayName) async {
    if (_userProfile == null) return false;

    final updatedProfile = _userProfile!.copyWith(displayName: displayName);
    return await updateProfile(updatedProfile);
  }

  // Clear error
  void clearError() {
    _error = null;
    _emailConfirmationRequired = false;
    notifyListeners();
  }
}

/*import 'package:flutter/foundation.dart';
import 'package:sample_app/config/supa_base_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Listen to auth state changes
    SupabaseConfig.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _currentUser = session.user;
        _loadUserProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _userProfile = null;
        notifyListeners();
      }
    });

    // Check if there's an existing session
    final session = SupabaseConfig.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
      await _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      final response = await SupabaseConfig.userProfiles
          .select()
          .eq('id', _currentUser!.id)
          .single();

      _userProfile = UserProfile.fromJson(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Profile might not exist yet, create one
      await _createUserProfile();
    }
  }

  Future<void> _createUserProfile() async {
    if (_currentUser == null) return;

    try {
      final profile = UserProfile(
        id: _currentUser!.id,
        displayName: _currentUser!.email ?? 'User',
      );

      await SupabaseConfig.userProfiles.insert(profile.toJson());
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName ?? email},
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        return true;
      }

      _error = 'Sign up failed';
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        return true;
      }

      _error = 'Sign in failed';
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
      _currentUser = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to send reset email';
      debugPrint('Password reset error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserProfile profile) async {
    if (_currentUser == null) return false;

    try {
      await SupabaseConfig.userProfiles
          .update(profile.toJson())
          .eq('id', _currentUser!.id);

      _userProfile = profile;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // Update display name
  Future<bool> updateDisplayName(String displayName) async {
    if (_userProfile == null) return false;

    final updatedProfile = _userProfile!.copyWith(displayName: displayName);
    return await updateProfile(updatedProfile);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
*/
