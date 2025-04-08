import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/user_provider.dart';
import 'package:frontend/views/screens/account_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../mocks/mocks.mocks.dart';

final client = MockClient();
final userProvider = MockUserProvider();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Account screen shows all buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccountScreen(),
      ),
    );

    expect(find.text(AppConfig.changePassword), findsOneWidget);
    expect(find.text(AppConfig.logout), findsOneWidget);
  });

  testWidgets('Tap on Change password navigates to form', (tester) async {
    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AccountScreen(),
        ),
        GoRoute(
          path: '/change_password',
          builder: (context, state) =>
              const Scaffold(key: Key(AppConfig.changePassword)),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppConfig.changePassword));
    await tester.pumpAndSettle();

    expect(find.byKey(Key(AppConfig.changePassword)), findsOneWidget);
  });

  testWidgets('User can log out successfully', (WidgetTester tester) async {
    when(userProvider.user).thenReturn(null);

    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AccountScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: ApiClient(client)),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: MaterialApp.router(routerConfig: goRouter),
    ),
  );

    await tester.tap(find.text(AppConfig.logout));

    await tester.pumpAndSettle();
  });
}
