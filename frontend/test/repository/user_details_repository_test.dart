import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/cooking_skills.dart';
import 'package:frontend/models/user_details/daily_budget.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid_value.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late UserDetailsRepository repository;
  late MockApiClient mockApiClient;
  late DietForm testDietForm;
  late Macros testMacros;
  late PredictedCalories testCalories;
  late UuidValue uuidUserId;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = UserDetailsRepository(mockApiClient);

    testDietForm = DietForm(
      gender: Gender.male,
      height: 180.0,
      weight: 75.0,
      dateOfBirth: DateTime.now(),
      dietType: DietType.fatLoss,
      allergies: [],
      dietGoal: 70.0,
      mealsPerDay: 4,
      dailyBudget: DailyBudget.medium,
      cookingSkills: CookingSkills.advanced,
      dietIntensity: DietIntensity.medium,
      activityLevel: ActivityLevel.moderate,
      stressLevel: StressLevel.high,
      sleepQuality: SleepQuality.good,
      musclePercentage: null,
      waterPercentage: null,
      fatPercentage: null,
    );

    testMacros = Macros(protein: 100, fat: 50, carbs: 200);

    testCalories = PredictedCalories(
      bmr: 1600,
      tdee: 2200,
      targetCalories: 2000,
      dietDurationDays: 30,
      predictedMacros: testMacros,
    );

    uuidUserId = UuidValue.fromString('c4b678c3-bb44-5b37-90d9-5b0c9a4f1b87');
  });

  group('submitDietForm', () {
    test(
      'should call apiClient.submitDietForm with correct parameters',
      () async {
        when(mockApiClient.submitDietForm(any, any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: '',
            statusCode: 200,
          ),
        );

        await repository.submitDietForm(testDietForm, uuidUserId);

        verify(
          mockApiClient.submitDietForm(testDietForm, uuidUserId),
        ).called(1);
      },
    );

    test('should throw ApiException when DioException occurs', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          data: {'error': 'Invalid data'},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );
      when(mockApiClient.submitDietForm(any, any)).thenThrow(dioError);

      expect(
        () => repository.submitDietForm(testDietForm, uuidUserId),
        throwsA(isA<ApiException>()),
      );
    });

    test('should throw Exception when other error occurs', () async {
      when(
        mockApiClient.submitDietForm(any, any),
      ).thenThrow(Exception('Network error'));

      expect(
        () => repository.submitDietForm(testDietForm, uuidUserId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getDietPreferences', () {
    test('should return DietForm when apiClient returns valid data', () async {
      when(mockApiClient.getDietPreferences(any)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: testDietForm.toJson(),
          statusCode: 200,
        ),
      );

      final result = await repository.getDietPreferences(uuidUserId);

      expect(result.gender, equals(testDietForm.gender));
      expect(result.height, equals(testDietForm.height));
      verify(mockApiClient.getDietPreferences(uuidUserId)).called(1);
    });

    test('should throw ApiException on DioException', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          data: {'error': 'Bad request'},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );
      when(mockApiClient.getDietPreferences(any)).thenThrow(dioError);

      expect(
        () => repository.getDietPreferences(uuidUserId),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('submitMacrosChange', () {
    test(
      'should call apiClient.submitMacrosChange with correct parameters',
      () async {
        when(mockApiClient.submitMacrosChange(any, any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: testCalories.toJson(),
          ),
        );

        await repository.submitMacrosChange(testMacros, uuidUserId);

        verify(
          mockApiClient.submitMacrosChange(testMacros, uuidUserId),
        ).called(1);
      },
    );

    test('should throw ApiException on DioException', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          data: {'error': 'Invalid macros'},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );

      when(mockApiClient.submitMacrosChange(any, any)).thenThrow(dioError);

      expect(
        () => repository.submitMacrosChange(testMacros, uuidUserId),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('addCaloriesPrediction', () {
    test(
      'should return PredictedCalories when apiClient returns valid data',
      () async {
        when(mockApiClient.addCaloriesPrediction(any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: testCalories.toJson(),
            statusCode: 200,
          ),
        );

        final result = await repository.addCaloriesPrediction(uuidUserId);

        expect(result.bmr, equals(testCalories.bmr));
        expect(
          result.predictedMacros.protein,
          equals(testCalories.predictedMacros.protein),
        );
        verify(mockApiClient.addCaloriesPrediction(uuidUserId)).called(1);
      },
    );

    test('should throw ApiException on DioException', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          data: {'error': 'Bad request'},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );

      when(mockApiClient.addCaloriesPrediction(any)).thenThrow(dioError);

      expect(
        () => repository.addCaloriesPrediction(uuidUserId),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('getCaloriesPrediction', () {
    test(
      'should return PredictedCalories when apiClient returns valid data',
      () async {
        when(mockApiClient.getCaloriesPrediction(any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: testCalories.toJson(),
            statusCode: 200,
          ),
        );

        final result = await repository.getCaloriesPrediction(uuidUserId);

        expect(result.tdee, equals(testCalories.tdee));
        expect(result.targetCalories, equals(testCalories.targetCalories));
        verify(mockApiClient.getCaloriesPrediction(uuidUserId)).called(1);
      },
    );

    test('should throw ApiException on DioException', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          data: {'error': 'Unauthorized'},
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      when(mockApiClient.getCaloriesPrediction(any)).thenThrow(dioError);

      expect(
        () => repository.getCaloriesPrediction(uuidUserId),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
