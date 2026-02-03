import 'package:flutter_test/flutter_test.dart';
import 'package:news/my_app.dart';
import 'package:news/screen/splash_screen.dart';

void main() {
  testWidgets('App smoke test - verifies splash screen is initial route', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen is displayed.
    expect(find.byType(SplashScreen), findsOneWidget);

    // To handle the Timer in SplashScreen, we need to pump until it's finished or use pumpAndSettle if it leads to a transition.
    // However, if we just want to verify the splash screen is there, we can just finish the test but we must handle the pending timer.
    // The easiest way to let the timer fire and the animation settle is:
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
