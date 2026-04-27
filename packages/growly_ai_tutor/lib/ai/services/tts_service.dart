import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../growly_core/lib/domain/models/child_profile.dart';

part 'tts_service.g.dart';

@riverpod
class TtsService extends _$TtsService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  @override
  TtsService build() {
    _flutterTts = FlutterTts();
    _initTts();
    ref.onDispose(() {
      _flutterTts.stop();
    });
    return this;
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

  bool get isSpeaking => _flutterTts.getisSpeaking as bool? ?? false;
}