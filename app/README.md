# Application Cavi-Medias (Flutter)

Application officielle du groupe Cavi-Medias pour Android et iPhone, design 2 « Studio ».

- **Accueil** : direct CaviTV à la une, accès Cavi FM et Siam Info, dernières infos.
- **CaviTV** : direct vidéo HLS, plein écran paysage, partage, son coupé ou actif.
- **Cavi FM** : direct radio avec lecture en arrière-plan et sur l'écran verrouillé, volume, minuterie de mise en veille, mini-lecteur visible dans les autres onglets.
- **Siam Info** : articles lus depuis l'API WordPress du site, lecture dans l'application et partage.
- **Plus** : présentation du groupe, contact (appel, WhatsApp, Messenger, e-mail, adresse), réseaux sociaux, réglages (lancement automatique de la vidéo), publicité, mentions légales.

## À compléter

Tout se règle dans `lib/config.dart` :

| Réglage | Rôle |
| --- | --- |
| `siamInfoSite`, `siamInfoWpApi` | Adresse de Siam Info et de son API WordPress (`https://…/wp-json/wp/v2`). Tant que l'API est vide, l'application affiche un encart « Lire Siam Info ». |
| `whatsapp`, `messenger` | Numéro WhatsApp et lien Messenger de la page Cavi TV. |
| `facebook`, `x`, `tiktok`, `instagram`, `youtube` | Pages du groupe. Un lien vide affiche « Lien bientôt disponible ». |
| `adUnitHome`, `adUnitTv`, `adUnitRadio` | Emplacements publicitaires AdMob (accueil, CaviTV, Cavi FM). Aucun identifiant n'est inséré : le point d'intégration est le widget `AdSlot` dans `lib/widgets/common.dart`. |

## Commandes

```bash
flutter pub get
flutter analyze
flutter test
flutter run                      # sur un téléphone branché
flutter build apk --release      # Android (APK)
flutter build appbundle          # Android (Google Play)
flutter build ipa                # iPhone (sur un Mac avec Xcode)
```

Chaque envoi sur GitHub lance l'analyse, les tests et la construction d'un APK de test
(onglet *Actions*, artefact `cavi-medias-apk`).

Icônes et écran de démarrage : images sources dans `branding/`, puis
`dart run flutter_launcher_icons` et `dart run flutter_native_splash:create`.

## Publication dans les stores

- Identifiant : `com.cavimedias.app` (Android et iOS).
- Google Play : créer une clé de signature (keystore) et la déclarer dans `android/key.properties`
  (fichier à ne jamais publier sur GitHub), puis `flutter build appbundle`.
- App Store : compte Apple Developer, signature dans Xcode, puis `flutter build ipa`.

Application réalisée par ConforDev — https://confordev.com

### Signature Google Play

Créer la clé d'envoi une seule fois (à conserver précieusement avec ses mots de passe,
elle est indispensable pour toutes les mises à jour) :

```bash
keytool -genkey -v -keystore C:\Users\User\cavi-medias-cles\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Puis créer `android/key.properties` (ignoré par Git) :

```
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=C:/Users/User/cavi-medias-cles/upload-keystore.jks
```

`flutter build appbundle --release` produit alors `build/app/outputs/bundle/release/app-release.aab`, signé pour Google Play.
