import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/news_screen.dart';
import 'screens/radio_screen.dart';
import 'screens/tv_screen.dart';
import 'services/radio_service.dart';
import 'theme.dart';
import 'widgets/mini_player.dart';
import 'widgets/nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await RadioService.initBackground();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: CaviColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const CaviMediasApp());
}

class CaviMediasApp extends StatelessWidget {
  const CaviMediasApp({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cavi-Medias',
      debugShowCheckedModeBanner: false,
      theme: buildCaviTheme(),
      darkTheme: buildCaviTheme(),
      themeMode: ThemeMode.dark,
      locale: const Locale('fr', 'FR'),
      home: AppShell(initialTab: initialTab),
    );
  }
}

/// Coquille de l'application : onglets, mini-lecteur et barre flottante.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = 0});
  final int initialTab;

  /// Hauteur réservée en bas des écrans pour la barre flottante.
  static const bottomInset = 110.0;

  static AppShellState? of(BuildContext context) => context.findAncestorStateOfType<AppShellState>();

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  late int _index = widget.initialTab;

  void select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final radio = RadioService.instance;
    return Scaffold(
      body: Stack(children: [
        IndexedStack(index: _index, children: [
          HomeScreen(onNavigate: select),
          TvScreen(active: _index == 1),
          const RadioScreen(),
          const NewsScreen(),
          const MoreScreen(),
        ]),
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListenableBuilder(
                listenable: radio,
                builder: (context, _) => AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: radio.isActive && _index != 2
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MiniPlayer(onOpen: () => select(2)),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ),
              FloatingNavBar(index: _index, onSelect: select),
            ]),
          ),
        ),
      ]),
    );
  }
}
