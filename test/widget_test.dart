import 'package:flutter_test/flutter_test.dart';
import 'package:personal_discipline_app/providers/habit_provider.dart';
import 'package:personal_discipline_app/providers/theme_provider.dart';
import 'package:personal_discipline_app/repositories/habit_repository.dart';
import 'package:personal_discipline_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('PersonalDisciplineApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = HabitRepository(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(create: (_) => HabitProvider(repo)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify navigation tabs exist
    expect(find.text('Thói quen'), findsWidgets);
    expect(find.text('Thống kê'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
  });
}
