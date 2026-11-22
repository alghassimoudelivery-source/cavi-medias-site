import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../config.dart';
import '../main.dart';
import '../services/links.dart';
import '../services/news_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

final _dateFormat = DateFormat('d MMMM y', 'fr_FR');

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _service = NewsService();
  final _articles = <Article>[];
  bool _loading = false;
  bool _done = false;
  String? _error;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    if (_service.isConfigured) _loadMore();
  }

  Future<void> _refresh() async {
    setState(() {
      _articles.clear();
      _page = 1;
      _done = false;
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _done) return;
    setState(() => _loading = true);
    try {
      final items = await _service.latest(count: 12, page: _page);
      setState(() {
        _articles.addAll(items);
        _page++;
        _done = items.length < 12;
        _error = null;
      });
    } catch (e) {
      setState(() {
        if (_articles.isEmpty) _error = 'Les articles de Siam Info ne peuvent pas être chargés pour le moment.';
        _done = _articles.isNotEmpty;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = Row(children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: CaviColors.blue, borderRadius: BorderRadius.circular(CaviRadius.tile)),
        child: const Icon(Icons.article_rounded, color: Colors.white),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Siam Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text('L\'actualité du groupe Cavi-Medias', style: TextStyle(fontSize: 13, color: CaviColors.sub)),
        ]),
      ),
      SquareIconButton(
        icon: Icons.open_in_new_rounded,
        label: 'Ouvrir le site Siam Info',
        onPressed: () => openLink(context, AppConfig.siamInfoSite, inApp: true),
      ),
    ]);

    final children = <Widget>[header, const SizedBox(height: 18)];
    if (!_service.isConfigured) {
      children.add(const SiamInfoSoonCard());
    } else if (_error != null) {
      children.add(StudioCard(child: ErrorPanel(message: _error!, onRetry: _refresh)));
    } else {
      for (var i = 0; i < _articles.length; i++) {
        children.add(i == 0 ? ArticleHeroCard(article: _articles[i]) : ArticleTile(article: _articles[i]));
        children.add(const SizedBox(height: 10));
      }
      if (_loading) {
        children.add(const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())));
      } else if (!_done) {
        children.add(Center(
          child: TextButton(
            onPressed: _loadMore,
            style: TextButton.styleFrom(foregroundColor: CaviColors.blueLight, minimumSize: const Size(44, 44)),
            child: const Text('Plus d\'articles'),
          ),
        ));
      }
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _service.isConfigured ? _refresh : () async {},
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, AppShell.bottomInset),
          children: children,
        ),
      ),
    );
  }
}

/// Encart affiché tant que l'API de Siam Info n'est pas configurée.
class SiamInfoSoonCard extends StatelessWidget {
  const SiamInfoSoonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SIAM INFO',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: CaviColors.blueLight)),
        const SizedBox(height: 6),
        const Text('Les articles arrivent bientôt dans l\'application',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3)),
        const SizedBox(height: 6),
        const Text('En attendant, retrouvez toute l\'actualité sur le site de Siam Info.',
            style: TextStyle(fontSize: 14, color: CaviColors.sub, height: 1.5)),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => openLink(context, AppConfig.siamInfoSite, inApp: true),
          style: FilledButton.styleFrom(
            backgroundColor: CaviColors.blue,
            minimumSize: const Size(44, 46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CaviRadius.tile)),
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('Lire Siam Info'),
        ),
      ]),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.width, required this.height, this.radius = 12});
  final String? url;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: CaviColors.card2,
      child: const Icon(Icons.image_outlined, color: CaviColors.sub),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null
          ? placeholder
          : Image.network(url!, width: width, height: height, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder),
    );
  }
}

void _openArticle(BuildContext context, Article a) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ArticleScreen(article: a)));
}

class ArticleTile extends StatelessWidget {
  const ArticleTile({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      padding: const EdgeInsets.all(10),
      onTap: () => _openArticle(context, article),
      child: Row(children: [
        _Thumb(url: article.imageUrl, width: 64, height: 64),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((article.category ?? 'Siam Info').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CaviColors.blueLight)),
            const SizedBox(height: 4),
            Text(article.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3)),
          ]),
        ),
      ]),
    );
  }
}

class ArticleHeroCard extends StatelessWidget {
  const ArticleHeroCard({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      padding: EdgeInsets.zero,
      onTap: () => _openArticle(context, article),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Thumb(url: article.imageUrl, width: double.infinity, height: 190, radius: 0),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((article.category ?? 'À la une').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CaviColors.blueLight)),
            const SizedBox(height: 6),
            Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 6),
            Text(_dateFormat.format(article.date), style: const TextStyle(fontSize: 12, color: CaviColors.sub)),
          ]),
        ),
      ]),
    );
  }
}

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siam Info'),
        actions: [
          IconButton(
            tooltip: 'Partager',
            onPressed: () => shareText(context, '${article.title}\n${article.link}'),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          if (article.imageUrl != null) ...[
            _Thumb(url: article.imageUrl, width: double.infinity, height: 210, radius: CaviRadius.card),
            const SizedBox(height: 18),
          ],
          Text((article.category ?? 'Siam Info').toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: CaviColors.blueLight)),
          const SizedBox(height: 8),
          Text(article.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.25)),
          const SizedBox(height: 8),
          Text(_dateFormat.format(article.date), style: const TextStyle(fontSize: 13, color: CaviColors.sub)),
          const SizedBox(height: 18),
          SelectableText(
            article.content.isNotEmpty ? article.content : article.excerpt,
            style: const TextStyle(fontSize: 16, height: 1.65),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => openLink(context, article.link, inApp: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: CaviColors.card2),
              minimumSize: const Size(44, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CaviRadius.tile)),
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Lire sur le site Siam Info'),
          ),
        ],
      ),
    );
  }
}
