import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late UserDetailsRepository repository;
  late MockApiClient mockApiClient;
  late DietForm testDietForm;
  const testUserId = 1;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = UserDetailsRepository(mockApiClient);
    testDietForm = DietForm(
      gender: Gender.male,
      height: 180.0,
      weight: 75.0,
      dateOfBirth: DateTime.now(),
      dietType: DietType.keto,
      allergies: [],
      dietGoal: 70.0,
      mealsPerDay: 4,
      dietIntensity: DietIntensity.medium,
      activityLevel: ActivityLevel.moderate,
      stressLevel: StressLevel.high,
      sleepQuality: SleepQuality.good,
      musclePercentage: null,
      waterPercentage: null,
      fatPercentage: null,
    );
  });

  group('submitDietForm', () {
    test(
      'should call apiClient.submitDietForm with correct parameters',
      () async {
        // Given
        when(mockApiClient.submitDietForm(any, any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: '',
            statusCode: 200,
          ),
        );

        // When
        await repository.submitDietForm(testDietForm, testUserId);

        // Then
        verify(
          mockApiClient.submitDietForm(testDietForm, testUserId),
        ).called(1);
      },
    );

    test('should throw ApiException when DioException occurs', () async {
      // Given
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          data: {'error': 'Invalid data'},
        ),
      );
      when(mockApiClient.submitDietForm(any, any)).thenThrow(dioError);

      // When, Then
      expect(
        () => repository.submitDietForm(testDietForm, testUserId),
        throwsA(isA<ApiException>()),
      );
    });

    test('should throw Exception when other error occurs', () async {
      // Given
      when(
        mockApiClient.submitDietForm(any, any),
      ).thenThrow(Exception('Network error'));

      // When, Then
      expect(
        () => repository.submitDietForm(testDietForm, testUserId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
