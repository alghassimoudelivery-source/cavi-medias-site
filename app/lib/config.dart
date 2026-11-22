/// Réglages de l'application Cavi-Medias.
///
/// Tous les liens et identifiants modifiables sont rassemblés ici.
/// Un lien vide ('') laisse le bouton en place : il affiche
/// « Lien bientôt disponible » jusqu'à ce que l'adresse soit renseignée.
class AppConfig {
  AppConfig._();

  static const appName = 'Cavi-Medias';
  static const website = 'https://cavimedias.com';
  static const legalUrl = 'https://cavimedias.com/mentions-legales/';
  static const advertisingUrl = 'https://cavimedias.com/publicite/';

  // ---------- Directs ----------
  static const tvStreamUrl = 'https://broadlio.com/hls/tv/cavi-tv.m3u8';
  static const radioStreamUrl = 'https://broadlio.com/fm/cavi-fm';

  // ---------- Siam Info ----------
  /// Adresse publique du site Siam Info (ouverte dans le navigateur).
  static const siamInfoSite = 'https://siaminfo.com';

  /// API WordPress de Siam Info, par exemple 'https://siaminfo.com/wp-json/wp/v2'.
  /// Laisser vide tant que le site n'est pas en ligne : l'application affiche
  /// alors un encart qui renvoie vers le site au lieu de la liste d'articles.
  static const siamInfoWpApi = '';

  // ---------- Contact ----------
  static const phone = '+224 624 39 74 76';
  static const email = 'contact@cavimedias.com';
  static const address =
      'Yimbaya carrefour Camp, Commune de Gbessia, Conakry, République de Guinée';

  /// Numéro WhatsApp au format international sans « + » ni espaces (ex. 224624397476).
  static const whatsapp = '';

  /// Lien Messenger de la page « Cavi TV » (ex. https://m.me/nomdelapage).
  static const messenger = '';

  // ---------- Réseaux sociaux ----------
  static const facebook = '';
  static const x = '';
  static const tiktok = '';
  static const instagram = '';
  static const youtube = '';

  // ---------- Publicité (emplacements uniquement) ----------
  /// Identifiants de blocs d'annonces AdMob, à renseigner plus tard.
  /// Tant qu'ils sont vides, aucun encart n'est affiché.
  static const adUnitHome = '';
  static const adUnitTv = '';
  static const adUnitRadio = '';
}
