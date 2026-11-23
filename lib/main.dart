import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/study_config.dart';
import 'firebase/firebase_init.dart';
import 'providers/providers.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open the encrypted database before the UI starts so the whole tree can
  // depend on a ready StorageService synchronously.
  //
  // SECURITY (MVP): the passphrase is a development placeholder. Production
  // should supply a device-held key from platform secure storage
  // (Keychain / Keystore) so no secret is hardcoded — see SECURITY_CHECKLIST.
  const devPassphrase = 'spark-dev-passphrase-change-me';
  final storage = await StorageService.open(passphrase: devPassphrase);

  // Load researcher-tunable timing from the bundled config; fall back to the
  // study-brief defaults if the asset is missing or malformed.
  final studyConfig = await _loadStudyConfig();

  // Initialize Firebase if it has been configured (`flutterfire configure`).
  // When false, cloud sync is disabled and the app runs offline-only.
  final firebaseAvailable = await initFirebaseIfConfigured();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        baseStudyConfigProvider.overrideWithValue(studyConfig),
        firebaseAvailableProvider.overrideWithValue(firebaseAvailable),
      ],
      child: const SparkApp(),
    ),
  );
}

Future<StudyConfig> _loadStudyConfig() async {
  try {
    final raw = await rootBundle.loadString('assets/config/study_config.json');
    final map = jsonDecode(raw) as Map<String, Object?>;
    return StudyConfig.fromJson(map);
  } catch (_) {
    return StudyConfig.defaults();
  }
}
