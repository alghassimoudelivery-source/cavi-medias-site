import 'package:material_ui/material_ui.dart';

import '../config.dart';
import '../main.dart';
import '../services/news_service.dart';
import '../services/radio_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'news_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, AppShell.bottomInset),
        children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/brand/cavi-medias-icone.png', width: 44, height: 44),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bienvenue sur', style: TextStyle(fontSize: 12, color: CaviColors.sub)),
                Text('Cavi-Medias',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
              ]),
            ),
            SquareIconButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Contacter la rédaction',
              onPressed: () => onNavigate(4),
            ),
          ]),
          const SizedBox(height: 16),
          _Segmented(onNavigate: onNavigate),
          const SizedBox(height: 18),
          _TvHeroCard(onTap: () => onNavigate(1)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _MediaTile(
                color: CaviColors.red,
                icon: Icons.radio_rounded,
                title: 'Cavi FM',
                subtitle: 'Radio en direct',
                onTap: () {
                  onNavigate(2);
                  final radio = RadioService.instance;
                  if (!radio.isActive) radio.play();
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MediaTile(
                color: CaviColors.blue,
                icon: Icons.article_rounded,
                title: 'Siam Info',
                subtitle: 'Toute l\'actualité',
                onTap: () => onNavigate(3),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          SectionTitle('Dernières infos', action: 'Tout voir', onAction: () => onNavigate(3)),
          const SizedBox(height: 6),
          const LatestNewsPreview(count: 3),
          const SizedBox(height: 14),
          const AdSlot(adUnitId: AppConfig.adUnitHome),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool selected, VoidCallback onTap) => Expanded(
          child: Semantics(
            button: true,
            selected: selected,
            child: Material(
              color: selected ? CaviColors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: onTap,
                child: SizedBox(
                  height: 42,
                  child: Center(
                    child: Text(label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : CaviColors.sub,
                        )),
                  ),
                ),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: CaviColors.card, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        seg('Direct', true, () {}),
        seg('Infos', false, () => onNavigate(3)),
        seg('Le groupe', false, () => onNavigate(4)),
      ]),
    );
  }
}

class _TvHeroCard extends StatelessWidget {
  const _TvHeroCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Regarder CaviTV en direct',
      child: Material(
        color: CaviColors.card,
        borderRadius: BorderRadius.circular(CaviRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 186,
              child: Stack(children: [
                const Positioned.fill(child: ColoredBox(color: CaviColors.blue)),
                const Positioned(
                  left: -40,
                  bottom: -70,
                  child: SizedBox(
                    width: 210,
                    height: 210,
                    child: DecoratedBox(decoration: BoxDecoration(color: CaviColors.violet, shape: BoxShape.circle)),
                  ),
                ),
                Positioned(
                  right: -24,
                  top: -24,
                  child: Opacity(
                    opacity: 0.18,
                    child: Image.asset('assets/brand/cavi-medias-icone.png', width: 150, height: 150),
                  ),
                ),
                const Positioned(left: 14, top: 14, child: LiveBadge()),
                Center(
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: CaviColors.blue, size: 36),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(children: [
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('CaviTV', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Regarder la chaîne en direct', style: TextStyle(fontSize: 13, color: CaviColors.sub)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0x2E2F6FE0), borderRadius: BorderRadius.circular(999)),
                  child: const Text('24 h/24',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CaviColors.blueLight)),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: StudioCard(
        onTap: onTap,
        child: SizedBox(
          height: 118,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(CaviRadius.tile)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: CaviColors.sub)),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// Aperçu des derniers articles Siam Info pour l'accueil.
class LatestNewsPreview extends StatefulWidget {
  const LatestNewsPreview({super.key, this.count = 3});
  final int count;

  @override
  State<LatestNewsPreview> createState() => _LatestNewsPreviewState();
}

class _LatestNewsPreviewState extends State<LatestNewsPreview> {
  final _service = NewsService();
  late Future<List<Article>> _future = _load();

  Future<List<Article>> _load() => _service.latest(count: widget.count);

  @override
  Widget build(BuildContext context) {
    if (!_service.isConfigured) return const SiamInfoSoonCard();
    return FutureBuilder<List<Article>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || (snap.data ?? []).isEmpty) {
          return StudioCard(
            child: ErrorPanel(
              message: 'Les articles de Siam Info ne peuvent pas être chargés pour le moment.',
              onRetry: () => setState(() => _future = _load()),
            ),
          );
        }
        return Column(children: [
          for (final a in snap.data!) ...[
            ArticleTile(article: a),
            const SizedBox(height: 10),
          ],
        ]);
      },
    );
  }
}
