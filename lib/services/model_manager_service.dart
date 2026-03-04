import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class ModelManagerService {
  final _dio = Dio();
  
  // URL to a lightweight Qwen 2.5 0.5B GGUF model optimized for edge devices
  static const String qwenModelUrl = 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf';
  static const String qwenModelFileName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf';
  
  // URL to Whisper Tiny Multilingual model
  static const String whisperModelUrl = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin';
  static const String whisperModelFileName = 'ggml-tiny.bin';

  Future<String> getModelPath() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return '${docsDir.path}/$qwenModelFileName';
  }

  Future<String> getWhisperModelPath() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return '${docsDir.path}/$whisperModelFileName';
  }

  Future<bool> isModelDownloaded() async {
    final path = await getModelPath();
    final file = File(path);
    if (!file.existsSync()) return false;
    
    // Check if the Qwen 2.5 0.5B model is fully downloaded (~398MB)
    final size = await file.length();
    if (size < 350 * 1024 * 1024) {
      // Delete corrupted or partial file
      try { await file.delete(); } catch (_) {}
      return false;
    }
    return true; 
  }

  Future<bool> isWhisperModelDownloaded() async {
    final path = await getWhisperModelPath();
    final file = File(path);
    if (!file.existsSync()) return false;
    
    // Check if the Whisper Tiny Multilingual model is fully downloaded (~75MB)
    final size = await file.length();
    if (size < 70 * 1024 * 1024) {
      // Delete corrupted or partial file
      try { await file.delete(); } catch (_) {}
      return false;
    }
    return true; 
  }

  Future<void> downloadModel({
    required Function(double progress) onProgress,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final path = await getModelPath();
      
      // We will perform a true download using Dio
      await _dio.download(
        qwenModelUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      
      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> downloadWhisperModel({
    required Function(double progress) onProgress,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final path = await getWhisperModelPath();
      
      await _dio.download(
        whisperModelUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      
      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }
}

final modelManagerProvider = Provider((ref) => ModelManagerService());
