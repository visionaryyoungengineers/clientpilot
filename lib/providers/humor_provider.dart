import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HumorLevel {
  professional,
  polite,
  friendly,
  casual,
  savage
}

class HumorNotifier extends StateNotifier<HumorLevel> {
  HumorNotifier() : super(HumorLevel.professional);

  void setHumorLevel(HumorLevel level) {
    state = level;
  }
}

final humorProvider = StateNotifierProvider<HumorNotifier, HumorLevel>((ref) {
  return HumorNotifier();
});
