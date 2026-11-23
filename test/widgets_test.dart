import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/core/constants.dart';
import 'package:spark/services/spark_session.dart';
import 'package:spark/widgets/reflection_rating_scale.dart';
import 'package:spark/widgets/spark_suggestion_card.dart';

void main() {
  testWidgets('SparkSuggestionCard fires accept and reject callbacks',
      (tester) async {
    var accepted = 0;
    var rejected = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SparkSuggestionCard(
          suggestion:
              const SparkSuggestion(text: 'Try a hidden power', aiGenerated: false),
          onAccept: () => accepted++,
          onReject: () => rejected++,
        ),
      ),
    ));

    // The suggestion text and child-facing copy are shown; no "AI" wording.
    expect(find.text('Try a hidden power'), findsOneWidget);
    expect(find.textContaining('AI'), findsNothing);

    await tester.tap(find.text(ChildCopy.accept));
    await tester.pump();
    await tester.tap(find.text(ChildCopy.reject));
    await tester.pump();

    expect(accepted, 1);
    expect(rejected, 1);
  });

  testWidgets('ReflectionRatingScale reports the tapped value',
      (tester) async {
    int? value;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ReflectionRatingScale(
          index: 1,
          question: ReflectionQuestions.ownership,
          value: value,
          onChanged: (v) => value = v,
        ),
      ),
    ));

    expect(find.text(ReflectionQuestions.ownership), findsOneWidget);
    // Five faces are rendered.
    expect(find.byType(GestureDetector), findsNWidgets(5));

    await tester.tap(find.byType(GestureDetector).at(4)); // highest rating
    await tester.pump();
    expect(value, 5);
  });
}
