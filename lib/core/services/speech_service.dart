import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  Function(String)? _onResult;

  Future<void> initialize() async {
    _available = await _speech.initialize(
      onStatus: _onStatus,
    );
  }

  void _onStatus(String status) {
    if ((status == 'done' || status == 'notListening') &&
        _onResult != null &&
        _available) {
      _startListeningInternal();
    }
  }

  Future<void> startListening({required Function(String) onResult}) async {
    _onResult = onResult;
    _startListeningInternal();
  }

  void _startListeningInternal() {
    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _onResult?.call(result.recognizedWords);
        }
      },
    );
  }

  Future<void> stopListening() async {
    _onResult = null;
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _available;
}
