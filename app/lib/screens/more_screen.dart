import 'package:material_ui/material_ui.dart';

import '../config.dart';
import '../main.dart';
import '../services/links.dart';
import '../services/prefs.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Onglet « Plus » : le groupe, contact, réseaux et réglages.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool? _autoplay;

  @override
  void initState() {
    super.initState();
    Prefs.autoplayTv().then((v) {
      if (mounted) setState(() => _autoplay = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, AppShell.bottomInset),
        children: [
          Center(child: Image.asset('assets/brand/cavi-medias-logo-horizontal-blanc.png', height: 40,
              semanticLabel: 'Cavi-Medias')),
          const SizedBox(height: 22),
          StudioCard(
            padding: const EdgeInsets.all(18),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Le groupe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                'Cavi-Medias est un groupe de presse guinéen qui réunit la chaîne de télévision CaviTV, '
                'la radio Cavi FM et le site d\'information Siam Info.',
                style: TextStyle(fontSize: 14, color: CaviColors.sub, height: 1.55),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          const _Heading('Nous contacter'),
          ActionRow(
            icon: Icons.phone_rounded,
            title: 'Appeler',
            subtitle: AppConfig.phone,
            onTap: () => openLink(context, telUrl(AppConfig.phone)),
          ),
          const SizedBox(height: 10),
          ActionRow(
            icon: Icons.chat_rounded,
            title: 'WhatsApp',
            subtitle: 'Écrire à la rédaction',
            iconBg: const Color(0x3325D366),
            iconColor: const Color(0xFF6EE29A),
            onTap: () => openLink(context, whatsappUrl(AppConfig.whatsapp)),
          ),
          const SizedBox(height: 10),
          ActionRow(
            icon: Icons.forum_rounded,
            title: 'Messenger',
            subtitle: 'Page Cavi TV',
            iconBg: const Color(0x335B55C9),
            iconColor: const Color(0xFFB7B2FF),
            onTap: () => openLink(context, AppConfig.messenger),
          ),
          const SizedBox(height: 10),
          ActionRow(
            icon: Icons.mail_rounded,
            title: 'E-mail',
            subtitle: AppConfig.email,
            onTap: () => openLink(context, mailUrl(AppConfig.email)),
          ),
          const SizedBox(height: 10),
          ActionRow(
            icon: Icons.place_rounded,
            title: 'Adresse',
            subtitle: AppConfig.address,
            iconBg: const Color(0x33E8262B),
            iconColor: CaviColors.redLight,
            onTap: () => openLink(
              context,
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(AppConfig.address)}',
            ),
          ),
          const SizedBox(height: 22),
          const _Heading('Suivez-nous'),
          const SocialRow(),
          const SizedBox(height: 22),
          const _Heading('Réglages'),
          StudioCard(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _autoplay ?? true,
              onChanged: _autoplay == null
                  ? null
                  : (v) {
                      setState(() => _autoplay = v);
                      Prefs.setAutoplayTv(v);
                    },
              title: const Text('Lancer CaviTV automatiquement',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              subtitle: const Text('Désactivez pour économiser vos données mobiles',
                  style: TextStyle(fontSize: 13, color: CaviColors.sub)),
            ),
          ),
          const SizedBox(height: 10),
          ActionRow(
            icon: Icons.campaign_rounded,
            title: 'Publicité',
            subtitle: 'Annoncer sur nos médias',
            onTap: () => openLink(context, AppConfig.advertisingUrl, inApp: true),
          ),
          const SizedBox(height: 10),
          ActionRow(
            icon: Icons.language_rounded,
            title: 'Site web',
            subtitle: 'cavimedias.com',
            onTap: () => openLink(context, AppConfig.website, inApp: true),
          ),
          const SizedBox(height: 10),
          ActionRow(
            icon: Icons.gavel_rounded,
            title: 'Mentions légales et confidentialité',
            onTap: () => openLink(context, AppConfig.legalUrl, inApp: true),
          ),
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: () => openLink(context, 'https://confordev.com'),
              style: TextButton.styleFrom(foregroundColor: CaviColors.sub, minimumSize: const Size(44, 44)),
              child: const Text('Application réalisée par ConforDev', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      );
}
