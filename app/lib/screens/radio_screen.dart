import 'package:material_ui/material_ui.dart';

import '../config.dart';
import '../main.dart';
import '../services/links.dart';
import '../services/radio_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final radio = RadioService.instance;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: radio,
        builder: (context, _) {
          final loading = radio.status == RadioStatus.loading;
          final error = radio.status == RadioStatus.error;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, AppShell.bottomInset),
            children: [
              Row(children: [
                SquareIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: 'Retour à l\'accueil',
                  onPressed: () => AppShell.of(context)?.select(0),
                ),
                const Expanded(
                  child: Text('Cavi FM',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                SquareIconButton(
                  icon: Icons.ios_share_rounded,
                  label: 'Partager',
                  onPressed: () => shareRadio(context),
                ),
              ]),
              const SizedBox(height: 28),
              Center(child: _Disc(playing: radio.isPlaying)),
              const SizedBox(height: 28),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0x29E8262B), borderRadius: BorderRadius.circular(999)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                      width: 7,
                      height: 7,
                      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFFF4B50), shape: BoxShape.circle)),
                    ),
                    SizedBox(width: 6),
                    Text('En direct',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CaviColors.redLight)),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Cavi FM',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text(
                error
                    ? 'La radio ne répond pas pour le moment.'
                    : loading
                        ? 'Connexion au direct…'
                        : 'La radio du groupe Cavi-Medias',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: CaviColors.sub),
              ),
              const SizedBox(height: 26),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SquareIconButton(
                  icon: radio.sleepAt == null ? Icons.bedtime_outlined : Icons.bedtime_rounded,
                  label: 'Minuterie de mise en veille',
                  size: 54,
                  radius: 18,
                  iconColor: radio.sleepAt == null ? Colors.white : CaviColors.blueLight,
                  onPressed: () => _pickSleepTimer(context),
                ),
                const SizedBox(width: 28),
                Semantics(
                  button: true,
                  label: radio.isPlaying ? 'Mettre la radio en pause' : 'Écouter Cavi FM',
                  child: Material(
                    color: CaviColors.blue,
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: radio.toggle,
                      child: SizedBox(
                        width: 84,
                        height: 84,
                        child: Center(
                          child: loading
                              ? const SizedBox(
                                  width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : Icon(radio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white, size: 42),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                SquareIconButton(
                  icon: Icons.stop_rounded,
                  label: 'Arrêter la radio',
                  size: 54,
                  radius: 18,
                  onPressed: radio.isActive ? radio.stop : null,
                ),
              ]),
              if (radio.sleepAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Arrêt automatique à ${TimeOfDay.fromDateTime(radio.sleepAt!).format(context)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: CaviColors.blueLight),
                ),
              ],
              if (error) ...[
                const SizedBox(height: 16),
                ErrorPanel(
                  message: 'Vérifiez votre connexion internet puis réessayez.',
                  onRetry: radio.play,
                  secondaryLabel: 'Ouvrir le lecteur web',
                  onSecondary: () => openLink(context, AppConfig.radioStreamUrl),
                ),
              ],
              const SizedBox(height: 26),
              Row(children: [
                const Icon(Icons.volume_mute_rounded, color: CaviColors.sub, size: 20),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: CaviColors.blue,
                      inactiveTrackColor: CaviColors.card2,
                      thumbColor: Colors.white,
                      trackHeight: 6,
                      overlayColor: const Color(0x332F6FE0),
                    ),
                    child: Slider(
                      value: radio.volume,
                      onChanged: radio.setVolume,
                      semanticFormatterCallback: (v) => 'Volume ${(v * 100).round()} %',
                    ),
                  ),
                ),
                const Icon(Icons.volume_up_rounded, color: CaviColors.sub, size: 20),
              ]),
              const SizedBox(height: 18),
              ActionRow(
                icon: Icons.phone_in_talk_rounded,
                title: 'Joindre le studio',
                subtitle: AppConfig.phone,
                iconBg: const Color(0x33E8262B),
                iconColor: CaviColors.redLight,
                onTap: () => openLink(context, telUrl(AppConfig.phone)),
              ),
              const SizedBox(height: 14),
              const AdSlot(adUnitId: AppConfig.adUnitRadio),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickSleepTimer(BuildContext context) async {
    final radio = RadioService.instance;
    final choice = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: CaviColors.card,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Arrêter la radio dans…', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          for (final m in [15, 30, 45, 60, 90])
            ListTile(title: Text('$m minutes'), onTap: () => Navigator.pop(ctx, m)),
          if (radio.sleepAt != null)
            ListTile(
              title: const Text('Annuler la minuterie', style: TextStyle(color: CaviColors.redLight)),
              onTap: () => Navigator.pop(ctx, 0),
            ),
        ]),
      ),
    );
    if (choice == null) return;
    if (choice == 0) {
      radio.cancelSleepTimer();
    } else {
      radio.setSleepTimer(Duration(minutes: choice));
    }
  }
}

/// Disque animé : anneaux bleu et violet autour du logo.
class _Disc extends StatefulWidget {
  const _Disc({required this.playing});
  final bool playing;

  @override
  State<_Disc> createState() => _DiscState();
}

class _DiscState extends State<_Disc> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    if (widget.playing) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_Disc old) {
    super.didUpdateWidget(old);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.playing && !reduce) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = _pulse.value;
        return Container(
          width: 270,
          height: 270,
          decoration: const BoxDecoration(color: CaviColors.card, shape: BoxShape.circle),
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: 226 + 8 * t,
              height: 226 + 8 * t,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CaviColors.blue.withValues(alpha: 0.45), width: 2),
              ),
            ),
            Container(
              width: 166 + 10 * t,
              height: 166 + 10 * t,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CaviColors.violet.withValues(alpha: 0.6), width: 2),
              ),
            ),
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(color: CaviColors.blue, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Image.asset('assets/brand/cavi-medias-icone.png', semanticLabel: 'Cavi-Medias'),
              ),
            ),
          ]),
        );
      },
    );
  }
}
