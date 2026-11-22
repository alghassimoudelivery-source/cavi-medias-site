import 'package:shared_preferences/shared_preferences.dart';

/// Préférences de l'utilisateur.
class Prefs {
  Prefs._();
  static const _autoplayTv = 'autoplay_tv';

  /// Lancer le direct CaviTV dès l'ouverture de l'onglet (désactivé = économie de données).
  static Future<bool> autoplayTv() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_autoplayTv) ?? true;
  }

  static Future<void> setAutoplayTv(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_autoplayTv, v);
  }
}
