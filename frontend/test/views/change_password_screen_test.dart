import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/events/change_password_events.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/change_password_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/change_password_states.dart';
import 'package:frontend/views/screens/change_password_screen.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late MockApiClient mockApiClient;
late AuthRepository authRepository;
late ChangePasswordBloc changePasswordBloc;
late MockTokenStorageRepository mockTokenStorageRepository;

Widget wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: authRepository),
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository)
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    authRepository = AuthRepository(mockApiClient);
    mockTokenStorageRepository = MockTokenStorageRepository();
    changePasswordBloc = ChangePasswordBloc(authRepository, mockTokenStorageRepository);
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Change password elements are displayed', (WidgetTester tester) async {
    // Given, When
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen(bloc: changePasswordBloc)));

    // Then
    expect(find.byKey(Key(AppConfig.email)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.newPassword)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.confirmPassword)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.changePassword)), findsOneWidget);
    expect(find.text(AppConfig.changePassword), findsNWidgets(2));

    expect(changePasswordBloc.state, isA<ChangePasswordInitial>());
  });

  testWidgets('Submit without filling form shows validation errors', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen(bloc: changePasswordBloc)));

    // When
    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    // Then
    expect(changePasswordBloc.state, isA<ChangePasswordInitial>());

    expect(find.text(AppConfig.requiredEmail), findsOneWidget);
    expect(find.text(AppConfig.requiredPassword), findsOneWidget);
    expect(find.text(AppConfig.requiredPasswordConfirmation), findsOneWidget);
  });

  testWidgets('Mismatched passwords show validation error', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen()));

    // When
    await tester.enterText(find.byKey(Key(AppConfig.email)), 'test@example.com');
    await tester.enterText(find.byKey(Key(AppConfig.newPassword)), 'Password123');
    await tester.enterText(find.byKey(Key(AppConfig.confirmPassword)), '321drowssaP');

    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.samePasswords), findsOneWidget);
  });
}
