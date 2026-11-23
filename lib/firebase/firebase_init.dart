import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// Initializes Firebase from the generated `firebase_options.dart`. Returns
/// whether Firebase is available (and therefore whether cloud sync can run).
///
/// On any failure (e.g. missing native config on a platform), it returns false
/// so the app degrades to offline-only rather than crashing at startup.
Future<bool> initFirebaseIfConfigured() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (_) {
    return false;
  }
}
