import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';

class TtsService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  TtsService() {
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('id-ID');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    _isInitialized = true;
  }

  Future<void> configureForAgeGroup(AgeGroup ageGroup) async {
    switch (ageGroup) {
      case AgeGroup.earlyChildhood:
        await _flutterTts.setSpeechRate(0.4);
        await _flutterTts.setPitch(1.1);
        break;
      case AgeGroup.primary:
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
        break;
      case AgeGroup.upperPrimary:
        await _flutterTts.setSpeechRate(0.55);
        await _flutterTts.setPitch(1.0);
        break;
      case AgeGroup.teen:
        await _flutterTts.setSpeechRate(0.6);
        await _flutterTts.setPitch(1.0);
        break;
    }
  }

  Future<void> speak(String text, {Function? onComplete}) async {
    if (!_isInitialized) await _initTts();

    _flutterTts.setCompletionHandler(() {
      onComplete?.call();
    });

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  bool get isSpeaking => false; // Placeholder - TTS state check requires async

  void dispose() {
    _flutterTts.stop();
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
});