import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../config.dart';
import '../main.dart';
import '../services/links.dart';
import '../services/prefs.dart';
import '../services/radio_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class TvScreen extends StatefulWidget {
  const TvScreen({super.key, required this.active});

  /// Vrai quand l'onglet CaviTV est affiché.
  final bool active;

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _loading = false;
  bool _failed = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.active) WidgetsBinding.instance.addPostFrameCallback((_) => _onShown());
  }

  @override
  void didUpdateWidget(TvScreen old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _onShown();
    } else if (!widget.active && old.active) {
      _controller?.pause();
      WakelockPlus.disable();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _controller?.pause();
  }

  Future<void> _onShown() async {
    final autoplay = await Prefs.autoplayTv();
    if (!mounted) return;
    if (autoplay || _started) _start();
  }

  Future<void> _start() async {
    _started = true;
    if (_controller != null && !_failed) {
      await RadioService.instance.pause();
      _controller!.play();
      WakelockPlus.enable();
      setState(() {});
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    final old = _controller;
    _controller = null;
    await old?.dispose();
    final c = VideoPlayerController.networkUrl(
      Uri.parse(AppConfig.tvStreamUrl),
      formatHint: VideoFormat.hls,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: false),
    );
    try {
      await c.initialize().timeout(const Duration(seconds: 25));
      if (!mounted) {
        await c.dispose();
        return;
      }
      c.addListener(_onControllerUpdate);
      await RadioService.instance.pause();
      await c.play();
      WakelockPlus.enable();
      setState(() {
        _controller = c;
        _loading = false;
      });
    } catch (e) {
      debugPrint('CaviTV : $e');
      await c.dispose();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _onControllerUpdate() {
    final c = _controller;
    if (c == null) return;
    if (c.value.hasError && !_failed) {
      setState(() => _failed = true);
    }
  }

  Future<void> _openFullscreen() async {
    final c = _controller;
    if (c == null) return;
    await Navigator.of(context).push(PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => _FullscreenPlayer(controller: c),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, AppShell.bottomInset),
        children: [
          _TopBar(
            title: 'CaviTV',
            onBack: () => AppShell.of(context)?.select(0),
            onShare: () => shareTv(context),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(CaviRadius.card),
            child: AspectRatio(aspectRatio: 16 / 9, child: _buildPlayer()),
          ),
          const SizedBox(height: 18),
          const StudioCard(
            padding: EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CaviTV en direct',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
              SizedBox(height: 8),
              Text(
                'Informations, débats, culture et divertissement depuis Conakry, 24 heures sur 24.',
                style: TextStyle(fontSize: 14, color: CaviColors.sub, height: 1.55),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          ActionRow(
            icon: Icons.forum_rounded,
            title: 'Réagir à l\'antenne',
            subtitle: 'Appel, WhatsApp ou Messenger',
            onTap: () => AppShell.of(context)?.select(4),
          ),
          const SizedBox(height: 14),
          ActionRow(
            icon: Icons.campaign_rounded,
            title: 'Annoncer sur CaviTV',
            subtitle: 'Nos offres publicitaires',
            iconBg: const Color(0x33E8262B),
            iconColor: CaviColors.redLight,
            onTap: () => openLink(context, AppConfig.advertisingUrl, inApp: true),
          ),
          const SizedBox(height: 14),
          const AdSlot(adUnitId: AppConfig.adUnitTv),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    final c = _controller;
    if (_failed) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ErrorPanel(
              message: 'Le direct ne peut pas être lu pour le moment.',
              onRetry: _start,
              secondaryLabel: 'Ouvrir le site',
              onSecondary: () => openLink(context, '${AppConfig.website}/cavitv/'),
            ),
          ),
        ),
      );
    }
    if (c == null || !c.value.isInitialized) {
      return Stack(fit: StackFit.expand, children: [
        const ColoredBox(color: Colors.black),
        Center(
          child: Opacity(
            opacity: 0.3,
            child: Image.asset('assets/brand/cavi-medias-icone.png', width: 72, height: 72),
          ),
        ),
        const Positioned(left: 14, top: 14, child: LiveBadge(solid: true)),
        Center(
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Semantics(
                  button: true,
                  label: 'Lancer le direct CaviTV',
                  child: GestureDetector(
                    onTap: _start,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(color: CaviColors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 38),
                    ),
                  ),
                ),
        ),
      ]);
    }
    return _PlayerView(controller: c, onFullscreen: _openFullscreen);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack, required this.onShare});
  final String title;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SquareIconButton(icon: Icons.arrow_back_ios_new_rounded, label: 'Retour à l\'accueil', onPressed: onBack),
      Expanded(
        child: Text(title,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      Builder(
        builder: (ctx) => SquareIconButton(icon: Icons.ios_share_rounded, label: 'Partager', onPressed: onShare),
      ),
    ]);
  }
}

/// Vidéo et barre de commandes.
class _PlayerView extends StatefulWidget {
  const _PlayerView({required this.controller, required this.onFullscreen, this.fullscreen = false});
  final VideoPlayerController controller;
  final VoidCallback onFullscreen;
  final bool fullscreen;

  @override
  State<_PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<_PlayerView> {
  bool _showControls = true;
  Timer? _hide;

  VideoPlayerController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_tick);
    _scheduleHide();
  }

  @override
  void dispose() {
    c.removeListener(_tick);
    _hide?.cancel();
    super.dispose();
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  void _scheduleHide() {
    _hide?.cancel();
    _hide = Timer(const Duration(seconds: 4), () {
      if (mounted && c.value.isPlaying) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  Future<void> _togglePlay() async {
    if (c.value.isPlaying) {
      await c.pause();
      WakelockPlus.disable();
    } else {
      await RadioService.instance.pause();
      await c.play();
      WakelockPlus.enable();
    }
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    final v = c.value;
    final muted = v.volume == 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: Stack(fit: StackFit.expand, children: [
        const ColoredBox(color: Colors.black),
        Center(
          child: AspectRatio(
            aspectRatio: v.aspectRatio > 0 ? v.aspectRatio : 16 / 9,
            child: VideoPlayer(c),
          ),
        ),
        if (v.isBuffering) const Center(child: CircularProgressIndicator(color: Colors.white)),
        AnimatedOpacity(
          opacity: _showControls || !v.isPlaying ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !(_showControls || !v.isPlaying),
            child: Stack(children: [
              const Positioned(left: 14, top: 14, child: LiveBadge(solid: true)),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: const Color(0xD9161C30), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    IconButton(
                      tooltip: v.isPlaying ? 'Pause' : 'Lecture',
                      onPressed: _togglePlay,
                      icon: Icon(v.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                    ),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(color: CaviColors.blue, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    IconButton(
                      tooltip: muted ? 'Activer le son' : 'Couper le son',
                      onPressed: () => c.setVolume(muted ? 1 : 0),
                      icon: Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white),
                    ),
                    IconButton(
                      tooltip: widget.fullscreen ? 'Quitter le plein écran' : 'Plein écran',
                      onPressed: widget.onFullscreen,
                      icon: Icon(widget.fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                          color: Colors.white),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _FullscreenPlayer extends StatefulWidget {
  const _FullscreenPlayer({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<_FullscreenPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _PlayerView(
        controller: widget.controller,
        fullscreen: true,
        onFullscreen: () => Navigator.of(context).pop(),
      ),
    );
  }
}
