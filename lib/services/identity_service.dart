import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Lightweight local identity until backend auth is connected.
/// - Generates a stable anonymous userId on first run
/// - Stores optional name/email/phone locally
class IdentityService {
  IdentityService._();
  static final IdentityService instance = IdentityService._();

  static const _prefsKey = 'winwithcasey.identity.v1';
  static const _nudgeDismissedKey = 'winwithcasey.profile_nudge_dismissed.v1';

  String _userId = '';
  String? _name;
  String? _email;
  String? _phone;
  bool _nudgeDismissed = false;

  String get userId => _userId;
  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  bool get isProfileComplete =>
      (_name != null && _name!.trim().isNotEmpty) &&
      (_email != null && _email!.trim().isNotEmpty) &&
      (_phone != null && _phone!.trim().isNotEmpty);
  bool get profileNudgeDismissed => _nudgeDismissed;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _userId = (map['userId'] as String?) ?? '';
        _name = map['name'] as String?;
        _email = map['email'] as String?;
        _phone = map['phone'] as String?;
      } catch (_) {
        // Corrupted entry, clear and regenerate below
        await prefs.remove(_prefsKey);
      }
    }

    // Load nudge dismissal flag
    _nudgeDismissed = prefs.getBool(_nudgeDismissedKey) ?? false;

    if (_userId.isEmpty) {
      // Generate a new anonymous id
      _userId = const Uuid().v4();
      await _persist();
    }
  }

  Future<void> updateProfile({String? name, String? email, String? phone}) async {
    _name = name?.trim().isEmpty == true ? null : name?.trim();
    _email = email?.trim().isEmpty == true ? null : email?.trim();
    _phone = phone?.trim().isEmpty == true ? null : phone?.trim();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'userId': _userId,
      if (_name != null) 'name': _name,
      if (_email != null) 'email': _email,
      if (_phone != null) 'phone': _phone,
    };
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  Future<void> setProfileNudgeDismissed(bool dismissed) async {
    _nudgeDismissed = dismissed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nudgeDismissedKey, dismissed);
  }
}
