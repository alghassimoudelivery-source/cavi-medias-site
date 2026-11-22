import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../config.dart';

enum RadioStatus { stopped, loading, playing, paused, error }

/// Lecture du direct Cavi FM, en arrière-plan et sur l'écran verrouillé.
class RadioService extends ChangeNotifier {
  RadioService._();
  static final RadioService instance = RadioService._();

  static bool _backgroundReady = false;

  /// À appeler une fois au démarrage, avant runApp.
  static Future<void> initBackground() async {
    if (kIsWeb || _backgroundReady) return;
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.cavimedias.app.radio',
        androidNotificationChannelName: 'Cavi FM en direct',
        androidNotificationOngoing: true,
      );
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _backgroundReady = true;
    } catch (e) {
      debugPrint('Lecture en arrière-plan indisponible : $e');
    }
  }

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _sub;
  RadioStatus _status = RadioStatus.stopped;
  double _volume = 1;
  Timer? _sleepTimer;
  DateTime? _sleepAt;

  RadioStatus get status => _status;
  bool get isActive =>
      _status == RadioStatus.playing ||
      _status == RadioStatus.loading ||
      _status == RadioStatus.paused;
  bool get isPlaying => _status == RadioStatus.playing;
  double get volume => _volume;
  DateTime? get sleepAt => _sleepAt;

  void _set(RadioStatus s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }

  Future<AudioPlayer> _ensurePlayer() async {
    final existing = _player;
    if (existing != null) return existing;
    final p = AudioPlayer();
    _player = p;
    _sub = p.playerStateStream.listen(
      (st) {
        if (st.processingState == ProcessingState.loading ||
            st.processingState == ProcessingState.buffering) {
          _set(RadioStatus.loading);
        } else if (st.playing && st.processingState == ProcessingState.ready) {
          _set(RadioStatus.playing);
        } else if (st.processingState == ProcessingState.completed) {
          _set(RadioStatus.stopped);
        } else if (!st.playing && _status != RadioStatus.stopped && _status != RadioStatus.error) {
          _set(RadioStatus.paused);
        }
      },
      onError: (Object e, StackTrace s) => _set(RadioStatus.error),
    );
    await p.setVolume(_volume);
    return p;
  }

  Future<void> play() async {
    _set(RadioStatus.loading);
    try {
      final p = await _ensurePlayer();
      if (p.audioSource == null || _status == RadioStatus.error) {
        await p.setAudioSource(
          AudioSource.uri(
            Uri.parse(AppConfig.radioStreamUrl),
            tag: const MediaItem(
              id: 'cavi-fm-direct',
              title: 'Cavi FM',
              artist: 'En direct · Cavi-Medias',
              album: 'Cavi FM',
            ),
          ),
        );
      }
      unawaited(p.play());
    } catch (e) {
      debugPrint('Cavi FM : $e');
      await _player?.stop();
      _set(RadioStatus.error);
    }
  }

  Future<void> pause() async => _player?.pause();

  Future<void> toggle() => isPlaying ? pause() : play();

  Future<void> stop() async {
    cancelSleepTimer();
    await _player?.stop();
    _set(RadioStatus.stopped);
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0, 1);
    notifyListeners();
    await _player?.setVolume(_volume);
  }

  void setSleepTimer(Duration d) {
    _sleepTimer?.cancel();
    _sleepAt = DateTime.now().add(d);
    _sleepTimer = Timer(d, () {
      _sleepAt = null;
      stop();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    if (_sleepAt != null) {
      _sleepAt = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player?.dispose();
    super.dispose();
  }
}
