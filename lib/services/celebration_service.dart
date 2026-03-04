import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final celebrationProvider = Provider<CelebrationService>((ref) {
  return CelebrationService();
});

class CelebrationService {
  final _controller = StreamController<String>.broadcast();
  
  Stream<String> get celebrationStream => _controller.stream;

  void celebrate(String message) {
    _controller.add(message);
  }

  void dispose() {
    _controller.close();
  }
}
