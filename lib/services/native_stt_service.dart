import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NativeSTTService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (err) => print('[STT] Error: $err'),
        onStatus: (status) => print('[STT] Status: $status'),
      );
    }
    return _isInitialized;
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) await initialize();
    
    if (_isInitialized) {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 120), // Max single session length
        pauseFor: const Duration(seconds: 5), // Auto-stop after 5s silence
        listenMode: stt.ListenMode.dictation,
      );
    } else {
      throw Exception('Speech recognition not initialized or denied.');
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}

final sttServiceProvider = Provider((ref) => NativeSTTService());
