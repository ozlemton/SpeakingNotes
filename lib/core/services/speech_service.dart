import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

const _mockSentences = [
  'Bugün toplantıda yeni proje hakkında konuştuk',
  'Flutter ile uygulama geliştirmek çok keyifli',
  'Clean Architecture kullanmak kodu düzenli tutuyor',
  'Kitap okuma listeme yeni kitaplar ekledim',
  'Haftalık hedeflerimi gözden geçirdim',
];

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  bool _initialized = false;
  bool _isListening = false;
  Function(String)? _onResult;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _available = await _speech.initialize(
        onStatus: _onStatus,
        onError: (error) => debugPrint('[SpeechService] onError: ${error.errorMsg} permanent=${error.permanent}'),
      );
      debugPrint('[SpeechService] initialize() returned: $_available');
      debugPrint('[SpeechService] isAvailable after init: ${_speech.isAvailable}');
      if (_available) {
        final locales = await _speech.locales();
        debugPrint('[SpeechService] available locales: ${locales.map((l) => l.localeId).toList()}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SpeechService.initialize failed: $e');
      _available = false;
    }
    _initialized = true;
  }

  void _onStatus(String status) {
    debugPrint('[SpeechService] onStatus: $status _isListening=$_isListening');
    if ((status == 'done' || status == 'notListening') &&
        _isListening &&
        _onResult != null &&
        _available) {
      debugPrint('[SpeechService] auto-restarting listen()');
      _startListeningInternal();
    }
  }

  Future<void> startListening({required Function(String) onResult}) async {
    debugPrint('[SpeechService] startListening called');
    if (!_initialized) {
      await initialize();
    }
    if (!_available) return;
    _onResult = onResult;
    _isListening = true;
    _startListeningInternal();
  }

  Future<void> _startListeningInternal() async {
    const listenFor = Duration(seconds: 30);
    const pauseFor = Duration(seconds: 3);
    final systemLocale = await _speech.systemLocale();
    debugPrint('[SpeechService] listen() — listenFor=$listenFor pauseFor=$pauseFor activeLocale=${systemLocale?.localeId ?? 'unknown'}');
    try {
      _speech.listen(
        onResult: (result) {
          debugPrint('[SpeechService] onResult: ${result.recognizedWords} final=${result.finalResult}');
          if (result.recognizedWords.isNotEmpty) {
            _onResult?.call(result.recognizedWords);
          }
        },
        onSoundLevelChange: (level) {
          debugPrint('[SpeechService] soundLevel: $level');
        },
        listenFor: listenFor,
        pauseFor: pauseFor,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SpeechService.listen failed: $e');
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    _onResult = null;
    try {
      await _speech.stop();
    } catch (e) {
      if (kDebugMode) debugPrint('SpeechService.stop failed: $e');
    }
  }

  String generateMockText() =>
      _mockSentences[Random().nextInt(_mockSentences.length)];

  bool get isListening => _speech.isListening;
  bool get isAvailable => _available;
}
