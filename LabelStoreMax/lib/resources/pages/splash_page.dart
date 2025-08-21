import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SplashPage extends StatelessWidget {
  static const String path = "/splash";
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 600));
      final String? model = await NyStorage.read(const StorageKey(key: 'FIRST_RUN_DEVICE_MODEL'));
      if (!context.mounted) return;
      NyNavigator.instance.router.navigateTo(context, model == null ? '/onboarding-device' : '/');
    });
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.build_circle, color: Colors.white, size: 72),
              const SizedBox(height: 16),
              Text('Mobile Troubleshooter', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

