import 'package:material_ui/material_ui.dart';

enum SocialIcon { facebook, x, tiktok, instagram, youtube }

/// Pictogrammes des réseaux sociaux.
class SocialGlyph extends StatelessWidget {
  const SocialGlyph(this.icon, {super.key, this.size = 20, this.color = Colors.white});
  final SocialIcon icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (icon) {
      case SocialIcon.facebook:
        return Icon(Icons.facebook, size: size, color: color);
      case SocialIcon.tiktok:
        return Icon(Icons.tiktok, size: size, color: color);
      case SocialIcon.youtube:
        return Icon(Icons.smart_display_rounded, size: size, color: color);
      case SocialIcon.instagram:
        return Container(
          width: size * 0.9,
          height: size * 0.9,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: size * 0.1),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Center(
            child: Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: size * 0.1)),
            ),
          ),
        );
      case SocialIcon.x:
        return Text('X',
            style: TextStyle(fontSize: size * 0.95, fontWeight: FontWeight.w800, color: color, height: 1));
    }
  }
}
