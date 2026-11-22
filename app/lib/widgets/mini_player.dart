import 'package:material_ui/material_ui.dart';

import '../services/radio_service.dart';
import '../theme.dart';

/// Mini-lecteur Cavi FM affiché au-dessus de la barre d'onglets.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final radio = RadioService.instance;
    return ListenableBuilder(
      listenable: radio,
      builder: (context, _) {
        final loading = radio.status == RadioStatus.loading;
        return Material(
          color: CaviColors.card,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: CaviColors.red, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.radio_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    const Text('Cavi FM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(loading ? 'Connexion…' : (radio.isPlaying ? 'En direct' : 'En pause'),
                        style: const TextStyle(fontSize: 12, color: CaviColors.sub)),
                  ]),
                ),
                IconButton(
                  tooltip: radio.isPlaying ? 'Pause' : 'Lecture',
                  onPressed: radio.toggle,
                  icon: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(radio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Arrêter la radio',
                  onPressed: radio.stop,
                  icon: const Icon(Icons.close_rounded, color: CaviColors.sub),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
