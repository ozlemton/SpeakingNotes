import 'dart:math';
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
  Function(String)? _onResult;

  Future<void> initialize() async {
    if (_initialized) return;
    _available = await _speech.initialize(
      onStatus: _onStatus,
    );
    _initialized = true;
  }

  void _onStatus(String status) {
    if ((status == 'done' || status == 'notListening') &&
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

  String generateMockText() =>
      _mockSentences[Random().nextInt(_mockSentences.length)];

  bool get isListening => _speech.isListening;
  bool get isAvailable => _available;
}
