import 'package:material_ui/material_ui.dart';

import '../config.dart';
import '../services/links.dart';
import '../theme.dart';
import 'social_icons.dart';

/// Pastille « En direct ».
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.solid = false, this.label = 'En direct'});
  final bool solid;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: solid ? CaviColors.red : const Color(0x99000000),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: solid ? Colors.white : const Color(0xFFFF4B50),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
      ]),
    );
  }
}

/// Bouton carré arrondi à icône (retour, partage…).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 44,
    this.color = CaviColors.card,
    this.iconColor = Colors.white,
    this.radius = 14,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final Color color;
  final Color iconColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: iconColor, size: size * 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte de base du design Studio.
class StudioCard extends StatelessWidget {
  const StudioCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CaviColors.card,
      borderRadius: BorderRadius.circular(CaviRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

/// Ligne de carte : icône colorée, titre, sous-titre, chevron.
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconBg = const Color(0x332F6FE0),
    this.iconColor = CaviColors.blueLight,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color iconBg;
  final Color iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      onTap: onTap,
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(CaviRadius.tile)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(fontSize: 13, color: CaviColors.sub)),
            ],
          ]),
        ),
        trailing ?? const Icon(Icons.chevron_right_rounded, color: CaviColors.sub),
      ]),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
      if (action != null)
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(foregroundColor: CaviColors.blueLight, minimumSize: const Size(44, 44)),
          child: Text(action!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}

/// Boutons des réseaux sociaux du groupe (liens dans config.dart).
class SocialRow extends StatelessWidget {
  const SocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, SocialIcon, String)>[
      ('Facebook', SocialIcon.facebook, AppConfig.facebook),
      ('X (Twitter)', SocialIcon.x, AppConfig.x),
      ('TikTok', SocialIcon.tiktok, AppConfig.tiktok),
      ('Instagram', SocialIcon.instagram, AppConfig.instagram),
      ('YouTube', SocialIcon.youtube, AppConfig.youtube),
    ];
    return Wrap(spacing: 10, runSpacing: 10, children: [
      for (final (name, icon, url) in items)
        Semantics(
          button: true,
          label: 'Cavi-Medias sur $name',
          child: Material(
            color: CaviColors.card,
            borderRadius: BorderRadius.circular(CaviRadius.tile),
            child: InkWell(
              borderRadius: BorderRadius.circular(CaviRadius.tile),
              onTap: () => openLink(context, url),
              child: SizedBox(width: 48, height: 48, child: Center(child: SocialGlyph(icon, size: 20))),
            ),
          ),
        ),
    ]);
  }
}

/// Emplacement publicitaire (AdMob). Rien n'est affiché tant que
/// l'identifiant du bloc est vide dans config.dart.
class AdSlot extends StatelessWidget {
  const AdSlot({super.key, required this.adUnitId, this.height = 60});
  final String adUnitId;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (adUnitId.isEmpty) return const SizedBox.shrink();
    // Point d'intégration : remplacer par la bannière AdMob
    // (package google_mobile_ads) une fois les identifiants fournis.
    return SizedBox(height: height);
  }
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message, this.onRetry, this.secondaryLabel, this.onSecondary});
  final String message;
  final VoidCallback? onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: CaviColors.sub, fontSize: 14, height: 1.5)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
        if (onRetry != null)
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: CaviColors.blue, minimumSize: const Size(44, 44)),
            child: const Text('Réessayer'),
          ),
        if (onSecondary != null)
          OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: CaviColors.card2),
              minimumSize: const Size(44, 44),
            ),
            child: Text(secondaryLabel ?? 'Ouvrir'),
          ),
      ]),
    ]);
  }
}
