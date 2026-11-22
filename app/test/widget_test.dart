import 'dart:convert';

import 'package:cavi_medias/main.dart';
import 'package:cavi_medias/services/news_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'autoplay_tv': false});
  });

  testWidgets('L\'accueil affiche les trois médias et la barre d\'onglets', (tester) async {
    await tester.pumpWidget(const CaviMediasApp());
    await tester.pump();

    expect(find.text('Cavi-Medias'), findsOneWidget);
    expect(find.text('CaviTV'), findsOneWidget);
    expect(find.text('Cavi FM'), findsOneWidget);
    expect(find.text('Siam Info'), findsWidgets);
    expect(find.bySemanticsLabel('Accueil'), findsOneWidget);
  });

  testWidgets('La barre d\'onglets ouvre l\'onglet Plus', (tester) async {
    await tester.pumpWidget(const CaviMediasApp());
    await tester.pump();

    await tester.tap(find.byTooltip('Plus'));
    await tester.pumpAndSettle();

    expect(find.text('Le groupe'), findsWidgets);
    expect(find.text('Nous contacter'), findsOneWidget);
    expect(find.text('+224 624 39 74 76'), findsOneWidget);
  });

  test('Lecture d\'un article WordPress de Siam Info', () async {
    final client = MockClient((req) async {
      expect(req.url.path, endsWith('/posts'));
      expect(req.url.queryParameters['_embed'], '1');
      return http.Response.bytes(
        utf8.encode('[{"id":7,"date":"2026-11-20T10:00:00","link":"https://exemple.test/a",'
                '"title":{"rendered":"L&rsquo;info du jour"},'
                '"excerpt":{"rendered":"<p>Résumé</p>"},'
                '"content":{"rendered":"<p>Premier paragraphe.</p><p>Second &amp; dernier.</p>"},'
                '"_embedded":{"wp:featuredmedia":[{"source_url":"https://exemple.test/i.jpg"}],'
                '"wp:term":[[{"name":"Politique"}]]}}]'),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = NewsService(client: client, apiBase: 'https://exemple.test/wp-json/wp/v2');
    final items = await service.latest(count: 1);

    expect(items, hasLength(1));
    expect(items.first.title, 'L’info du jour');
    expect(items.first.category, 'Politique');
    expect(items.first.imageUrl, 'https://exemple.test/i.jpg');
    expect(items.first.content, contains('Second & dernier.'));
  });

  test('Siam Info non configuré signale l\'indisponibilité', () async {
    final service = NewsService(apiBase: '');
    expect(service.isConfigured, isFalse);
    expect(service.latest(), throwsA(isA<NewsUnavailable>()));
  });
}
