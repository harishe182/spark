import 'package:flutter/cupertino.dart';

/// iOS-style page transitions for the whole app.
Future<T?> pushSparkPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    CupertinoPageRoute<T>(builder: (_) => page),
  );
}

Future<T?> pushSparkReplacement<T, TO>(BuildContext context, Widget page) {
  return Navigator.of(context).pushReplacement<T, TO>(
    CupertinoPageRoute<T>(builder: (_) => page),
  );
}
