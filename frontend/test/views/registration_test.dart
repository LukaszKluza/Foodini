import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/blocs/register_bloc.dart';
import 'package:frontend/events/register_events.dart';
import 'package:frontend/models/register_request.dart';
import 'package:frontend/models/user_response.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/views/screens/register_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../mocks/mocks.mocks.dart';

Widget wrapWithProviders(Widget child) {
  final mockAuthRepository = MockAuthRepository();
  final mockTokenStorageRepository = MockTokenStorageRepository();

  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: mockAuthRepository),
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository)
    ],
    child: MaterialApp(home: child),
  );
}
//TOREMOVE
void printAllWidgets(WidgetTester tester) {
  print('--- Widoczne teksty na ekranie ---');

  final renderView = tester.binding.renderView;
  final visibleTexts = tester.widgetList<Text>(find.byType(Text)).where((textWidget) {
    final element = tester.element(find.byWidget(textWidget));
    final renderObject = element.renderObject;
    final offset = renderObject?.getTransformTo(renderView)?.getTranslation();

    // Sprawdź, czy widget ma widoczny offset na ekranie (nie offstage / niewidoczny)
    return offset != null && offset.z == 0.0;
  });

  for (final text in visibleTexts) {
    final content = text.data?.trim();
    if (content != null && content.isNotEmpty) {
      print('- "$content"');
    }
  }

  print('--- Koniec widocznych tekstów ---');
}


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late MockAuthRepository mockAuthRepository;
  late RegisterBloc registerBloc;

  setUp(() {
    mockDio = MockDio();
    mockAuthRepository = MockAuthRepository();
    registerBloc = MockRegisterBloc();
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Register screen elements are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Register button triggers registration process', (WidgetTester tester) async {
    final response = Response(
      requestOptions: RequestOptions(path: AppConfig.registerUrl),
      data: {"message": "OK"},
      statusCode: 200,
    );

    when(mockDio.post(
      AppConfig.registerUrl,
      data: anyNamed("data"),
      options: anyNamed("options"),
    )).thenAnswer((_) async => response);

    when(mockAuthRepository.register(any)).thenAnswer((_) async {
      return UserResponse(
        id: 1,
        email: "test@onet.pl"
      );
    });

    final goRouter = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => RegisterScreen()),
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    await tester.pumpWidget(wrapWithProviders(MaterialApp.router(routerConfig: goRouter)));

    await tester.enterText(find.byKey(Key(AppConfig.firstName)), 'John');
    await tester.enterText(find.byKey(Key(AppConfig.lastName)), 'Doe');
    await tester.enterText(find.byKey(Key(AppConfig.email)),'john@example.com');
    await tester.enterText(find.byKey(Key(AppConfig.password)), 'password123');
    await tester.enterText(find.byKey(Key(AppConfig.confirmPassword)),'password123');

    await tester.tap(find.byKey(Key(AppConfig.age)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('18'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key(AppConfig.country)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Argentina'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppConfig.register));
    await tester.pumpAndSettle();

    verify(registerBloc.add(argThat(isA<RegisterRequest>()))).called(1);
  });

  testWidgets('Registration without filled form', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsNWidgets(2));
    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Select your age'), findsOneWidget);
    expect(find.text('Select your country'), findsOneWidget);
    expect(find.text('Password confirmation is required'), findsOneWidget);
  });

  testWidgets('Registration with different passwords', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    await tester.enterText(find.byKey(Key(AppConfig.password)), 'password123');
    await tester.enterText(
      find.byKey(Key(AppConfig.confirmPassword)),
      '321drowddap',
    );

    await tester.tap(find.byKey(Key(AppConfig.register)));
    await tester.pumpAndSettle();

    expect(find.text('Passwords must be the same'), findsOneWidget);
  });
}
