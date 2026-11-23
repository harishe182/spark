import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/widgets/spark_character.dart';

/// A minimal smoke test that the Spark logo renders without throwing. The
/// full app requires an opened encrypted database, so app-level boot is
/// exercised on a device/emulator rather than in host unit tests.
void main() {
  testWidgets('SparkCharacter paints without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: SparkCharacter(size: 120)),
        ),
      ),
    );
    expect(find.byType(SparkCharacter), findsOneWidget);
  });
}
