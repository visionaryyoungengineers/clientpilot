import 'dart:async';
import 'package:record/record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioRecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  Future<void> startRecording(String filePath) async {
    if (await hasPermission()) {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000, 
          numChannels: 1
        ),
        path: filePath,
      );
    } else {
      throw Exception('Microphone permission not granted.');
    }
  }

  Future<String?> stopRecording() async {
    return await _audioRecorder.stop();
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}

final audioRecordingServiceProvider = Provider<AudioRecordingService>((ref) {
  return AudioRecordingService();
});
