import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/model_manager_service.dart';

/// STT Model Download Sheet — shown on first launch if model not found.
/// Checks SharedPreferences flag 'stt_model_downloaded' to skip on subsequent launches.
class SttDownloadSheet extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const SttDownloadSheet({super.key, required this.onComplete});
  @override ConsumerState<SttDownloadSheet> createState() => _SttDownloadSheetState();
}

class _SttDownloadSheetState extends ConsumerState<SttDownloadSheet> {
  _Stage _stage = _Stage.idle;
  bool _error = false;
  double _progress = 0.0;
  String _errorMessage = '';

  Future<void> _startDownload() async {
    setState(() { _stage = _Stage.downloading; _progress = 0; _error = false; });

    final modelManager = ref.read(modelManagerProvider);
    await modelManager.downloadModel(
      onProgress: (p) {
        if (mounted) setState(() { _progress = p * 0.8; _errorMessage = "Qwen Model (~400 MB)"; });
      },
      onSuccess: () async {
        // Now download Whisper
        await modelManager.downloadWhisperModel(
          onProgress: (p) {
            if (mounted) setState(() { _progress = 0.8 + (p * 0.2); _errorMessage = "Whisper Model (~75 MB)"; });
          },
          onSuccess: () async {
            if (!mounted) return;
            setState(() { _stage = _Stage.success; });
            // Persist flag so we never show this sheet again
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('stt_model_downloaded', true);
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) widget.onComplete();
          },
          onError: (e) {
            if (mounted) setState(() { _error = true; _errorMessage = e; _stage = _Stage.idle; });
          }
        );
      },
      onError: (e) {
        if (mounted) setState(() { _error = true; _errorMessage = e; _stage = _Stage.idle; });
      },
    );
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withAlpha(50), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),

        AnimatedContainer(duration: const Duration(milliseconds: 400),
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _stage == _Stage.success ? const Color(0xFF16A34A).withAlpha(20) : _error ? theme.colorScheme.error.withAlpha(20) : theme.colorScheme.primary.withAlpha(20),
          ),
          child: Icon(
            _stage == _Stage.success ? LucideIcons.circleCheck : _error ? LucideIcons.circleX : LucideIcons.mic,
            size: 36,
            color: _stage == _Stage.success ? const Color(0xFF16A34A) : _error ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          _stage == _Stage.idle ? 'AI Voice Model Required' :
          _stage == _Stage.downloading ? 'Downloading Model...' : _error ? 'Download Failed' : 'Model Ready! ✅',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        Text(
          _error
              ? 'Error: $_errorMessage'
              : _stage == _Stage.idle
                  ? 'The Qwen 2.5 AI reasoning model (~400 MB) is needed to process voice recordings. Download once, works offline forever.'
                  : _stage == _Stage.success
                      ? 'Your AI voice assistant is ready. Closing...'
                      : 'Downloading... Please keep the app open.',
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(150), height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        if (_stage == _Stage.downloading) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _progress, minHeight: 8, backgroundColor: theme.colorScheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary)),
          ),
          const SizedBox(height: 8),
          Text('${(_progress * 100).round()}%  ·  $_errorMessage remaining',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
        ],

        if (_stage == _Stage.idle)
          SizedBox(width: double.infinity, child: FilledButton.icon(
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Download & Continue'),
            onPressed: _startDownload,
          )),
        if (_stage == _Stage.success)
          const SizedBox(width: double.infinity, child: FilledButton(onPressed: null, child: Text('✅ Closing...'))),
        if (_error)
          SizedBox(width: double.infinity, child: Column(children: [
            FilledButton.icon(icon: const Icon(LucideIcons.refreshCw, size: 16), label: const Text('Retry'), onPressed: _startDownload),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: widget.onComplete, child: const Text('Skip for now')),
          ])),
      ]),
    );
  }
}

enum _Stage { idle, downloading, success }
