import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class Article {
  Article({
    required this.id,
    required this.title,
    required this.link,
    required this.date,
    this.excerpt = '',
    this.content = '',
    this.imageUrl,
    this.category,
  });

  final int id;
  final String title;
  final String link;
  final DateTime date;
  final String excerpt;
  final String content;
  final String? imageUrl;
  final String? category;

  static final _unescape = HtmlUnescape();

  /// Supprime les balises HTML et décode les entités.
  static String plain(String html) {
    final noTags = html
        .replaceAll(RegExp(r'<(br|/p|/h\d|/li)[^>]*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '');
    return _unescape
        .convert(noTags)
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n+'), '\n\n')
        .trim();
  }

  factory Article.fromWordPress(Map<String, dynamic> j) {
    String? image;
    String? category;
    final embedded = j['_embedded'];
    if (embedded is Map) {
      final media = embedded['wp:featuredmedia'];
      if (media is List && media.isNotEmpty && media.first is Map) {
        image = (media.first as Map)['source_url'] as String?;
      }
      final terms = embedded['wp:term'];
      if (terms is List && terms.isNotEmpty && terms.first is List && (terms.first as List).isNotEmpty) {
        category = ((terms.first as List).first as Map)['name'] as String?;
      }
    }
    String rendered(String key) => ((j[key] as Map?)?['rendered'] as String?) ?? '';
    return Article(
      id: (j['id'] as num).toInt(),
      title: plain(rendered('title')),
      link: (j['link'] as String?) ?? AppConfig.siamInfoSite,
      date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
      excerpt: plain(rendered('excerpt')),
      content: plain(rendered('content')),
      imageUrl: image,
      category: category == null ? null : plain(category),
    );
  }
}

class NewsUnavailable implements Exception {
  const NewsUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Articles de Siam Info, lus depuis l'API WordPress du site.
class NewsService {
  NewsService({http.Client? client, String? apiBase})
      : _client = client ?? http.Client(),
        _apiBase = apiBase ?? AppConfig.siamInfoWpApi;

  final http.Client _client;
  final String _apiBase;

  bool get isConfigured => _apiBase.isNotEmpty;

  Future<List<Article>> latest({int count = 10, int page = 1}) async {
    if (!isConfigured) {
      throw const NewsUnavailable('Le flux Siam Info n\'est pas encore configuré.');
    }
    final uri = Uri.parse('$_apiBase/posts').replace(queryParameters: {
      'per_page': '$count',
      'page': '$page',
      '_embed': '1',
    });
    final res = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw NewsUnavailable('Siam Info ne répond pas (${res.statusCode}).');
    }
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body is! List) throw const NewsUnavailable('Réponse inattendue de Siam Info.');
    return body.whereType<Map<String, dynamic>>().map(Article.fromWordPress).toList();
  }
}
