import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── User Model ───────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email};

  factory UserModel.fromMap(Map<String, dynamic> m) =>
      UserModel(id: m['id'], name: m['name'], email: m['email']);
}

// ─── Auth State ───────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
  }) => AuthState(
    user:      user      ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    error:     error,
  );
}

// ─── Auth Notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkSession();
  }

  static const _keyUser     = 'auth_user';
  static const _keyUsers    = 'auth_users_db';
  static const _keyLoggedIn = 'auth_logged_in';

  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isIn  = prefs.getBool(_keyLoggedIn) ?? false;
    if (!isIn) return;
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return;
    final user = UserModel.fromMap(jsonDecode(userJson));
    state = state.copyWith(user: user, isLoggedIn: true);
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs    = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString(_keyUsers);
      final users    = usersRaw != null
          ? Map<String, dynamic>.from(jsonDecode(usersRaw))
          : <String, dynamic>{};

      if (users.containsKey(email)) {
        state = state.copyWith(isLoading: false, error: 'Email already registered');
        return false;
      }

      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      users[email] = {
        'id':       userId,
        'name':     name,
        'email':    email,
        'password': _hashPassword(password),
      };

      await prefs.setString(_keyUsers, jsonEncode(users));

      final user = UserModel(id: userId, name: name, email: email);
      await prefs.setString(_keyUser, jsonEncode(user.toMap()));
      await prefs.setBool(_keyLoggedIn, true);

      state = state.copyWith(user: user, isLoggedIn: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs    = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString(_keyUsers);
      if (usersRaw == null) {
        state = state.copyWith(isLoading: false, error: 'No account found. Please register.');
        return false;
      }

      final users = Map<String, dynamic>.from(jsonDecode(usersRaw));
      if (!users.containsKey(email)) {
        state = state.copyWith(isLoading: false, error: 'Email not found');
        return false;
      }

      final userData = users[email] as Map<String, dynamic>;
      if (userData['password'] != _hashPassword(password)) {
        state = state.copyWith(isLoading: false, error: 'Incorrect password');
        return false;
      }

      final user = UserModel(
        id:    userData['id'],
        name:  userData['name'],
        email: email,
      );
      await prefs.setString(_keyUser, jsonEncode(user.toMap()));
      await prefs.setBool(_keyLoggedIn, true);

      state = state.copyWith(user: user, isLoggedIn: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyUser);
    state = const AuthState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);
