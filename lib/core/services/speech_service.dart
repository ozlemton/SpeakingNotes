import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  bool _initialized = false;
  bool _isListening = false;
  Function(String)? _onResult;
  String _localeId = 'tr-TR';

  void setLocale(String languageCode) {
    _localeId = languageCode == 'en' ? 'en-US' : 'tr-TR';
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _available = await _speech.initialize(
        onStatus: _onStatus,
        onError: (error) {
          if (kDebugMode) debugPrint('SpeechService onError: ${error.errorMsg}');
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SpeechService.initialize failed: $e');
      _available = false;
    }
    _initialized = true;
  }

  void _onStatus(String status) {
    if ((status == 'done' || status == 'notListening') &&
        _isListening &&
        _onResult != null &&
        _available) {
      _startListeningInternal();
    }
  }

  Future<void> startListening({required Function(String) onResult}) async {
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
    try {
      _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            _onResult?.call(result.recognizedWords);
          }
        },
        listenFor: listenFor,
        pauseFor: pauseFor,
        localeId: _localeId,
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

  bool get isListening => _speech.isListening;
  bool get isAvailable => _available;
}
