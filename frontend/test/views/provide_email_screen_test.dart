import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/provide_email_block.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/provide_email_states.dart';
import 'package:frontend/views/screens/provide_email_screen.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late MockApiClient mockApiClient;
late AuthRepository authRepository;
late ProvideEmailBloc provideEmailBloc;
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
    provideEmailBloc = ProvideEmailBloc(authRepository);
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Provide email elements are displayed', (WidgetTester tester) async {
    // Given, When
    await tester.pumpWidget(wrapWithProviders(ProvideEmailScreen(bloc: provideEmailBloc)));

    // Then
    expect(find.byKey(Key(AppConfig.email)), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    expect(provideEmailBloc.state, isA<ProvideEmailInitial>());
  });

  testWidgets('Submit without filling form shows validation errors', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(ProvideEmailScreen(bloc: provideEmailBloc)));

    // When
    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    // Then
    expect(provideEmailBloc.state, isA<ProvideEmailInitial>());

    expect(find.text(AppConfig.requiredEmail), findsOneWidget);
  });
}
