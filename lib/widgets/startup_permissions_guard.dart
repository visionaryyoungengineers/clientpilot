import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../router/app_router.dart';

class StartupPermissionsGuard extends StatefulWidget {
  final Widget child;

  const StartupPermissionsGuard({super.key, required this.child});

  @override
  State<StartupPermissionsGuard> createState() => _StartupPermissionsGuardState();
}

class _StartupPermissionsGuardState extends State<StartupPermissionsGuard> {
  bool _initialized = false;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await [
      Permission.microphone,
    ].request();

    setState(() {
      _permissionsGranted = status[Permission.microphone]!.isGranted;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Microphone permission is required for AI Transcription.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings'),
              )
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
