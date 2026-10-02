import 'package:flutter_test/flutter_test.dart';

import 'package:mobiflex_job_application/main.dart';

void main() {
  testWidgets('MobiFlex job application loads', (tester) async {
    await tester.pumpWidget(const MobiFlexJobApplication());

    expect(find.text('Online Job Application'), findsOneWidget);
    expect(find.text('Position'), findsOneWidget);
    expect(find.text('Highest Qualification'), findsOneWidget);
  });
}
