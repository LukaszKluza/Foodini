import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user_details/change_password_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/states/change_password_states.dart';
import 'package:frontend/views/screens/user/change_password_screen.dart';

import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

late MockDio mockDio;
late MockApiClient mockApiClient;
late AuthRepository authRepository;
late ChangePasswordBloc changePasswordBloc;
late MockTokenStorageRepository mockTokenStorageRepository;

void main() {
  Widget buildTestWidget(Widget child) {
    return TestWrapperBuilder(child).build();
  }

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    authRepository = AuthRepository(mockApiClient);
    mockTokenStorageRepository = MockTokenStorageRepository();
    changePasswordBloc = ChangePasswordBloc(
      authRepository,
      mockTokenStorageRepository,
    );
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Change password elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(
      buildTestWidget(ChangePasswordScreen(bloc: changePasswordBloc)),
    );

    // Then
    expect(find.byKey(Key('e-mail')), findsOneWidget);
    expect(find.byKey(Key('new_password')), findsOneWidget);
    expect(find.byKey(Key('confirm_password')), findsOneWidget);
    expect(find.byKey(Key('change_password')), findsOneWidget);
    expect(find.text("Change password"), findsNWidgets(2));
    expect(find.byIcon(Icons.translate_rounded), findsOneWidget);

    expect(changePasswordBloc.state, isA<ChangePasswordInitial>());
  });

  testWidgets('Submit without filling form shows validation errors', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(ChangePasswordScreen(bloc: changePasswordBloc)),
    );

    // When
    await tester.tap(find.byKey(Key("change_password")));
    await tester.pumpAndSettle();

    // Then
    expect(changePasswordBloc.state, isA<ChangePasswordInitial>());

    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Password confirmation is required'), findsOneWidget);
  });

  testWidgets('Mismatched passwords show validation error', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(ChangePasswordScreen()));

    // When
    await tester.enterText(find.byKey(Key('e-mail')), 'test@example.com');
    await tester.enterText(find.byKey(Key('new_password')), 'Password123');
    await tester.enterText(find.byKey(Key('confirm_password')), '321drowssaP');

    await tester.tap(find.byKey(Key('change_password')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Passwords must be the same'), findsOneWidget);
  });
}
