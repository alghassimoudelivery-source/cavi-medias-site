import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

/// Ouvre un lien externe ; un lien vide affiche « Lien bientôt disponible ».
Future<void> openLink(BuildContext context, String url, {bool inApp = false}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (url.isEmpty) {
    messenger?.showSnackBar(const SnackBar(content: Text('Lien bientôt disponible')));
    return;
  }
  final ok = await launchUrl(
    Uri.parse(url),
    mode: inApp ? LaunchMode.inAppBrowserView : LaunchMode.externalApplication,
  );
  if (!ok) {
    messenger?.showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir ce lien')));
  }
}

String telUrl(String phone) => 'tel:${phone.replaceAll(' ', '')}';
String mailUrl(String email) => 'mailto:$email';
String whatsappUrl(String number) => number.isEmpty ? '' : 'https://wa.me/$number';

Future<void> shareText(BuildContext context, String text, {String? subject}) async {
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(ShareParams(
    text: text,
    subject: subject,
    sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
  ));
}

Future<void> shareTv(BuildContext context) => shareText(
      context,
      'Regardez CaviTV en direct sur l\'application Cavi-Medias : ${AppConfig.website}/cavitv/',
      subject: 'CaviTV en direct',
    );

Future<void> shareRadio(BuildContext context) => shareText(
      context,
      'Écoutez Cavi FM en direct sur l\'application Cavi-Medias : ${AppConfig.website}/cavi-fm/',
      subject: 'Cavi FM en direct',
    );
