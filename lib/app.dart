import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/providers.dart';
import 'screens/facilitator_login_screen.dart';

/// Root widget. The app opens on the facilitator side (login → participants);
/// child-facing screens are only reached by the facilitator starting a
/// session, so a child never sees setup or condition labels.
///
/// It also owns the cloud-sync flush loop: on startup and whenever an
/// unmetered (Wi-Fi) connection returns, it attempts to upload any queued
/// sessions. No-op when Firebase isn't configured.
class SparkApp extends ConsumerStatefulWidget {
  const SparkApp({super.key});

  @override
  ConsumerState<SparkApp> createState() => _SparkAppState();
}

class _SparkAppState extends ConsumerState<SparkApp> {
  StreamSubscription<bool>? _wifiSub;

  @override
  void initState() {
    super.initState();
    // Flush once at startup, then on every Wi-Fi (re)connection.
    unawaited(ref.read(syncServiceProvider).syncPending());
    _wifiSub =
        ref.read(connectivityServiceProvider).onWifiChanged.listen((onWifi) {
      if (onWifi) {
        unawaited(ref.read(syncServiceProvider).syncPending());
      }
    });
  }

  @override
  void dispose() {
    _wifiSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: SparkTheme.build(),
      builder: (context, child) => CupertinoTheme(
        data: SparkTheme.cupertino(context),
        child: child!,
      ),
      home: const FacilitatorLoginScreen(),
    );
  }
}
