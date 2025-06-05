import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @foodini.
  ///
  /// In en, this message translates to:
  /// **'Foodini'**
  String get foodini;

  /// No description provided for @hey.
  ///
  /// In en, this message translates to:
  /// **'Hey'**
  String get hey;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Foodini Home Page'**
  String get homePage;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome in Foodini'**
  String get welcome;

  /// No description provided for @requiredName.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get requiredName;

  /// No description provided for @provideCorrectName.
  ///
  /// In en, this message translates to:
  /// **'Provide correct name'**
  String get provideCorrectName;

  /// No description provided for @requiredCountry.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get requiredCountry;

  /// No description provided for @requiredEmail.
  ///
  /// In en, this message translates to:
  /// **'E-mail is required'**
  String get requiredEmail;

  /// No description provided for @requiredPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get requiredPassword;

  /// No description provided for @requiredPasswordConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get requiredPasswordConfirmation;

  /// No description provided for @samePasswords.
  ///
  /// In en, this message translates to:
  /// **'Passwords must be the same'**
  String get samePasswords;

  /// No description provided for @passwordLengthMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Password length must be between'**
  String get passwordLengthMustBeBetween;

  /// No description provided for @passwordComplexityError.
  ///
  /// In en, this message translates to:
  /// **'Password must contain letters (capital and lowercase) and numbers'**
  String get passwordComplexityError;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid e-mail'**
  String get invalidEmail;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAnAccount;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Do not have an account'**
  String get dontHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get forgotPassword;

  /// No description provided for @successfullyLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged in'**
  String get successfullyLoggedIn;

  /// No description provided for @successfullyLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Account logged out successfully'**
  String get successfullyLoggedOut;

  /// No description provided for @successfullyDeletedAccount.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get successfullyDeletedAccount;

  /// No description provided for @accountActivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account has been activated successfully'**
  String get accountActivatedSuccessfully;

  /// No description provided for @accountHasNotBeenConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your account has not been confirmed.'**
  String get accountHasNotBeenConfirmed;

  /// No description provided for @successfullyResendEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email account verification send successfully'**
  String get successfullyResendEmailVerification;

  /// No description provided for @sendVerificationEmailAgain.
  ///
  /// In en, this message translates to:
  /// **'Send verification email again'**
  String get sendVerificationEmailAgain;

  /// No description provided for @accountDeletionInformation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get accountDeletionInformation;

  /// No description provided for @confirmAccountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get confirmAccountDeletion;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @checkAndConfirmEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Check and confirm your email address'**
  String get checkAndConfirmEmailAddress;

  /// No description provided for @checkEmailAddressToSetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Check your email address to set new password'**
  String get checkEmailAddressToSetNewPassword;

  /// No description provided for @passwordSuccessfullyChanged.
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed'**
  String get passwordSuccessfullyChanged;

  /// No description provided for @wrongChangePasswordUrl.
  ///
  /// In en, this message translates to:
  /// **'You can\'t access change password form'**
  String get wrongChangePasswordUrl;

  /// No description provided for @dietPreferences.
  ///
  /// In en, this message translates to:
  /// **'Diet preferences'**
  String get dietPreferences;

  /// No description provided for @dietType.
  ///
  /// In en, this message translates to:
  /// **'Diet type'**
  String get dietType;

  /// No description provided for @requiredDietType.
  ///
  /// In en, this message translates to:
  /// **'Diet type is required'**
  String get requiredDietType;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @dietGoal.
  ///
  /// In en, this message translates to:
  /// **'Diet goal'**
  String get dietGoal;

  /// No description provided for @enterYourDietGoal.
  ///
  /// In en, this message translates to:
  /// **'Enter your diet goal'**
  String get enterYourDietGoal;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @dietGoalShouldBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Diet goal should be between'**
  String get dietGoalShouldBeBetween;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @mealsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Meals per day'**
  String get mealsPerDay;

  /// No description provided for @dietIntensity.
  ///
  /// In en, this message translates to:
  /// **'Diet intensity'**
  String get dietIntensity;

  /// No description provided for @requiredDietIntensity.
  ///
  /// In en, this message translates to:
  /// **'Diet intensity is required'**
  String get requiredDietIntensity;

  /// No description provided for @caloriesPrediction.
  ///
  /// In en, this message translates to:
  /// **'Calories prediction'**
  String get caloriesPrediction;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activityLevel;

  /// No description provided for @requiredActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity level is required'**
  String get requiredActivityLevel;

  /// No description provided for @stressLevel.
  ///
  /// In en, this message translates to:
  /// **'Stress level'**
  String get stressLevel;

  /// No description provided for @requiredStressLevel.
  ///
  /// In en, this message translates to:
  /// **'Stress level is required'**
  String get requiredStressLevel;

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get sleepQuality;

  /// No description provided for @requiredSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality is required'**
  String get requiredSleepQuality;

  /// No description provided for @advancedBodyParameters.
  ///
  /// In en, this message translates to:
  /// **'Advance body parameters'**
  String get advancedBodyParameters;

  /// No description provided for @musclePercentage.
  ///
  /// In en, this message translates to:
  /// **'Muscle percentage'**
  String get musclePercentage;

  /// No description provided for @enterMusclePercentage.
  ///
  /// In en, this message translates to:
  /// **'Enter your muscle %'**
  String get enterMusclePercentage;

  /// No description provided for @musclePercentageShouldBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Muscle % should be between'**
  String get musclePercentageShouldBeBetween;

  /// No description provided for @waterPercentage.
  ///
  /// In en, this message translates to:
  /// **'Water percentage'**
  String get waterPercentage;

  /// No description provided for @enterWaterPercentage.
  ///
  /// In en, this message translates to:
  /// **'Enter your water percentage'**
  String get enterWaterPercentage;

  /// No description provided for @waterPercentageShouldBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Water % should be %'**
  String get waterPercentageShouldBeBetween;

  /// No description provided for @fatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Fat percentage'**
  String get fatPercentage;

  /// No description provided for @enterFatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Enter your fat percentage'**
  String get enterFatPercentage;

  /// No description provided for @fatPercentageShouldBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Fat % should be %'**
  String get fatPercentageShouldBeBetween;

  /// No description provided for @generateWeeklyDiet.
  ///
  /// In en, this message translates to:
  /// **'Generate weekly diet'**
  String get generateWeeklyDiet;

  /// No description provided for @dietType_FatLoss.
  ///
  /// In en, this message translates to:
  /// **'Fat Loss'**
  String get dietType_FatLoss;

  /// No description provided for @dietType_MuscleGain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get dietType_MuscleGain;

  /// No description provided for @dietType_WeightMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Weight Maintenance'**
  String get dietType_WeightMaintenance;

  /// No description provided for @dietType_Vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietType_Vegetarian;

  /// No description provided for @dietType_Vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietType_Vegan;

  /// No description provided for @dietType_Keto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get dietType_Keto;

  /// No description provided for @allergy_Gluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get allergy_Gluten;

  /// No description provided for @allergy_Peanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergy_Peanuts;

  /// No description provided for @allergy_Lactose.
  ///
  /// In en, this message translates to:
  /// **'Lactose'**
  String get allergy_Lactose;

  /// No description provided for @allergy_Fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergy_Fish;

  /// No description provided for @allergy_Soy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergy_Soy;

  /// No description provided for @allergy_Wheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get allergy_Wheat;

  /// No description provided for @allergy_Celery.
  ///
  /// In en, this message translates to:
  /// **'Celery'**
  String get allergy_Celery;

  /// No description provided for @allergy_Sulphites.
  ///
  /// In en, this message translates to:
  /// **'Sulphites'**
  String get allergy_Sulphites;

  /// No description provided for @allergy_Lupin.
  ///
  /// In en, this message translates to:
  /// **'Lupin'**
  String get allergy_Lupin;

  /// No description provided for @dietIntensity_Slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get dietIntensity_Slow;

  /// No description provided for @dietIntensity_Medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get dietIntensity_Medium;

  /// No description provided for @dietIntensity_Fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get dietIntensity_Fast;

  /// No description provided for @activityLevel_VeryLow.
  ///
  /// In en, this message translates to:
  /// **'Very Low (1–2 days a week or less)'**
  String get activityLevel_VeryLow;

  /// No description provided for @activityLevel_Light.
  ///
  /// In en, this message translates to:
  /// **'Low (2–3 days a week)'**
  String get activityLevel_Light;

  /// No description provided for @activityLevel_Moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate (3–4 days a week)'**
  String get activityLevel_Moderate;

  /// No description provided for @activityLevel_Active.
  ///
  /// In en, this message translates to:
  /// **'Active (5–6 days a week)'**
  String get activityLevel_Active;

  /// No description provided for @activityLevel_VeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active (daily activity)'**
  String get activityLevel_VeryActive;

  /// No description provided for @stressLevel_Low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get stressLevel_Low;

  /// No description provided for @stressLevel_Medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get stressLevel_Medium;

  /// No description provided for @stressLevel_High.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get stressLevel_High;

  /// No description provided for @stressLevel_Extreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get stressLevel_Extreme;

  /// No description provided for @sleepQuality_Poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get sleepQuality_Poor;

  /// No description provided for @sleepQuality_Fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get sleepQuality_Fair;

  /// No description provided for @sleepQuality_Good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get sleepQuality_Good;

  /// No description provided for @sleepQuality_Excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get sleepQuality_Excellent;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get profileDetails;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @requiredGender.
  ///
  /// In en, this message translates to:
  /// **'Gender is required'**
  String get requiredGender;

  /// No description provided for @gender_Male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_Male;

  /// No description provided for @gender_Female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_Female;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @enterYourHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get enterYourHeight;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @heightShouldBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Height should be between'**
  String get heightShouldBeBetween;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @enterYourWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get enterYourWeight;

  /// No description provided for @weightShouldBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Weight should be between'**
  String get weightShouldBeBetween;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @formSuccessfullySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Form successfully submitted'**
  String get formSuccessfullySubmitted;

  /// No description provided for @fillAllNecessaryFields.
  ///
  /// In en, this message translates to:
  /// **'Fill all necessary fields'**
  String get fillAllNecessaryFields;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
