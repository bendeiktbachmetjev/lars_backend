import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_lt.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lt'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'iLARS'**
  String get appTitle;

  /// Application name for app store
  ///
  /// In en, this message translates to:
  /// **'iLARS'**
  String get appName;

  /// Dashboard tab label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Weekly time period label
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly time period label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Yearly time period label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Today's questionnaire section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Questionnaire'**
  String get todaysQuestionnaire;

  /// Daily questionnaire name
  ///
  /// In en, this message translates to:
  /// **'Daily Questionnaire'**
  String get dailyQuestionnaire;

  /// Weekly questionnaire name
  ///
  /// In en, this message translates to:
  /// **'Weekly Questionnaire (LARS)'**
  String get weeklyQuestionnaire;

  /// Monthly questionnaire name
  ///
  /// In en, this message translates to:
  /// **'Monthly Questionnaire'**
  String get monthlyQuestionnaire;

  /// Quality of life questionnaire name
  ///
  /// In en, this message translates to:
  /// **'Quality of Life Questionnaire (EQ-5D-5L)'**
  String get qualityOfLifeQuestionnaire;

  /// Message when no questionnaire is needed
  ///
  /// In en, this message translates to:
  /// **'No questionnaire needed'**
  String get noQuestionnaireNeeded;

  /// Message when all questionnaires are completed
  ///
  /// In en, this message translates to:
  /// **'All questionnaires are up to date'**
  String get allQuestionnairesUpToDate;

  /// Button to fill questionnaire
  ///
  /// In en, this message translates to:
  /// **'Fill It Now'**
  String get fillItNow;

  /// Message when patient code is not set
  ///
  /// In en, this message translates to:
  /// **'Please set your patient code in Profile'**
  String get pleaseSetPatientCode;

  /// Error message when questionnaire info fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load questionnaire info'**
  String get failedToLoadQuestionnaireInfo;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message prompting to complete weekly questionnaires
  ///
  /// In en, this message translates to:
  /// **'Complete weekly questionnaires to see your LARS score statistics'**
  String get completeWeeklyQuestionnairesToSeeStatistics;

  /// Message when need more data for trends
  ///
  /// In en, this message translates to:
  /// **'Complete more weekly questionnaires to see improvement trends'**
  String get completeMoreWeeklyQuestionnaires;

  /// Patient profile title
  ///
  /// In en, this message translates to:
  /// **'iLARS Patient'**
  String get ilarsPatient;

  /// Message when no patient code is set
  ///
  /// In en, this message translates to:
  /// **'No patient code'**
  String get noPatientCode;

  /// Patient code display
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String code(String code);

  /// Patient code field label
  ///
  /// In en, this message translates to:
  /// **'Patient Code'**
  String get patientCode;

  /// Placeholder for patient code input
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get enterYourCode;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Success message when patient code is saved
  ///
  /// In en, this message translates to:
  /// **'Patient code saved'**
  String get patientCodeSaved;

  /// Message when patient code is cleared
  ///
  /// In en, this message translates to:
  /// **'Patient code cleared'**
  String get patientCodeCleared;

  /// Daily questionnaire screen title
  ///
  /// In en, this message translates to:
  /// **'Daily Symptoms'**
  String get dailySymptoms;

  /// Stool count per day label
  ///
  /// In en, this message translates to:
  /// **'Stool/day'**
  String get stoolPerDay;

  /// Pads used label
  ///
  /// In en, this message translates to:
  /// **'Pads used'**
  String get padsUsed;

  /// Urgent label
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// Night stools label
  ///
  /// In en, this message translates to:
  /// **'Night stools'**
  String get nightStools;

  /// Yes option
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No option
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Stool leakage label
  ///
  /// In en, this message translates to:
  /// **'Stool leakage'**
  String get stoolLeakage;

  /// None option
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Liquid option
  ///
  /// In en, this message translates to:
  /// **'Liquid'**
  String get liquid;

  /// Solid option
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get solid;

  /// Incomplete evacuation label
  ///
  /// In en, this message translates to:
  /// **'Incomplete evacuation'**
  String get incompleteEvacuation;

  /// Bloating label
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get bloating;

  /// Impact on life label
  ///
  /// In en, this message translates to:
  /// **'Impact on life'**
  String get impactOnLife;

  /// Food consumption question
  ///
  /// In en, this message translates to:
  /// **'What did you consume today?'**
  String get whatDidYouConsumeToday;

  /// Drink consumption question
  ///
  /// In en, this message translates to:
  /// **'What did you drink today?'**
  String get whatDidYouDrinkToday;

  /// Quantity label with unit
  ///
  /// In en, this message translates to:
  /// **'Quantity ({unit}):'**
  String quantity(String unit);

  /// Bristol scale selector title
  ///
  /// In en, this message translates to:
  /// **'Stool Consistency'**
  String get stoolConsistency;

  /// Submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Success message after submission
  ///
  /// In en, this message translates to:
  /// **'Submitted successfully'**
  String get submittedSuccessfully;

  /// Error message when submission fails
  ///
  /// In en, this message translates to:
  /// **'Submit failed: {statusCode}'**
  String submitFailed(int statusCode);

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// Weekly questionnaire screen title
  ///
  /// In en, this message translates to:
  /// **'LARS Score Questionnaire'**
  String get larsScoreQuestionnaire;

  /// Flatus control question
  ///
  /// In en, this message translates to:
  /// **'Do you ever have occasions when you cannot control your flatus (wind)?'**
  String get flatusControlQuestion;

  /// Liquid stool leakage question
  ///
  /// In en, this message translates to:
  /// **'Do you ever have any accidental leakage of liquid stool?'**
  String get liquidStoolLeakageQuestion;

  /// Bowel frequency question
  ///
  /// In en, this message translates to:
  /// **'How often do you open your bowels?'**
  String get bowelFrequencyQuestion;

  /// Repeat bowel opening question
  ///
  /// In en, this message translates to:
  /// **'Do you ever have to open your bowels again within one hour of the last bowel opening?'**
  String get repeatBowelOpeningQuestion;

  /// Urgency to toilet question
  ///
  /// In en, this message translates to:
  /// **'Do you ever have such a strong urge to open your bowels that you have to rush to the toilet?'**
  String get urgencyToToiletQuestion;

  /// Total score label
  ///
  /// In en, this message translates to:
  /// **'Total Score:'**
  String get totalScore;

  /// No never option
  ///
  /// In en, this message translates to:
  /// **'No, never'**
  String get noNever;

  /// Yes less than once per week option
  ///
  /// In en, this message translates to:
  /// **'Yes, less than once per week'**
  String get yesLessThanOncePerWeek;

  /// Yes at least once per week option
  ///
  /// In en, this message translates to:
  /// **'Yes, at least once per week'**
  String get yesAtLeastOncePerWeek;

  /// More than 7 times per day option
  ///
  /// In en, this message translates to:
  /// **'More than 7 times per day (24 hours)'**
  String get moreThan7TimesPerDay;

  /// Times per day option with range
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} times per day (24 hours)'**
  String timesPerDay(String min, String max);

  /// Less than once per day option
  ///
  /// In en, this message translates to:
  /// **'Less than once per day (24 hours)'**
  String get lessThanOncePerDay;

  /// Monthly questionnaire screen title
  ///
  /// In en, this message translates to:
  /// **'Monthly Quality of Life '**
  String get monthlyQualityOfLife;

  /// Avoid traveling question
  ///
  /// In en, this message translates to:
  /// **'I avoid traveling due to bowel problems'**
  String get avoidTraveling;

  /// Avoid social activities question
  ///
  /// In en, this message translates to:
  /// **'I avoid social activities'**
  String get avoidSocialActivities;

  /// Feel embarrassed question
  ///
  /// In en, this message translates to:
  /// **'I feel embarrassed by my condition'**
  String get feelEmbarrassed;

  /// Worry others notice question
  ///
  /// In en, this message translates to:
  /// **'I worry others will notice my symptoms'**
  String get worryOthersNotice;

  /// Feel depressed question
  ///
  /// In en, this message translates to:
  /// **'I feel depressed because of bowel function'**
  String get feelDepressed;

  /// Feel in control question
  ///
  /// In en, this message translates to:
  /// **'I feel in control of my bowel symptoms'**
  String get feelInControl;

  /// Overall satisfaction question
  ///
  /// In en, this message translates to:
  /// **'Overall satisfaction with bowel function'**
  String get overallSatisfaction;

  /// EQ-5D-5L questionnaire screen title
  ///
  /// In en, this message translates to:
  /// **'EQ-5D-5L Questionnaire'**
  String get eq5d5lQuestionnaire;

  /// Mobility category
  ///
  /// In en, this message translates to:
  /// **'MOBILITY'**
  String get mobility;

  /// Self-care category
  ///
  /// In en, this message translates to:
  /// **'SELF-CARE'**
  String get selfCare;

  /// Usual activities category
  ///
  /// In en, this message translates to:
  /// **'USUAL ACTIVITIES'**
  String get usualActivities;

  /// Usual activities with description
  ///
  /// In en, this message translates to:
  /// **'USUAL ACTIVITIES\n(e.g. work, study, housework, family or leisure activities)'**
  String get usualActivitiesDescription;

  /// Pain/discomfort category
  ///
  /// In en, this message translates to:
  /// **'PAIN / DISCOMFORT'**
  String get painDiscomfort;

  /// Anxiety/depression category
  ///
  /// In en, this message translates to:
  /// **'ANXIETY / DEPRESSION'**
  String get anxietyDepression;

  /// No problems walking option
  ///
  /// In en, this message translates to:
  /// **'I have no problems in walking about'**
  String get noProblemsWalking;

  /// Slight problems walking option
  ///
  /// In en, this message translates to:
  /// **'I have slight problems in walking about'**
  String get slightProblemsWalking;

  /// Moderate problems walking option
  ///
  /// In en, this message translates to:
  /// **'I have moderate problems in walking about'**
  String get moderateProblemsWalking;

  /// Severe problems walking option
  ///
  /// In en, this message translates to:
  /// **'I have severe problems in walking about'**
  String get severeProblemsWalking;

  /// Unable to walk option
  ///
  /// In en, this message translates to:
  /// **'I am unable to walk about'**
  String get unableToWalk;

  /// No problems washing option
  ///
  /// In en, this message translates to:
  /// **'I have no problems washing or dressing myself'**
  String get noProblemsWashing;

  /// Slight problems washing option
  ///
  /// In en, this message translates to:
  /// **'I have slight problems washing or dressing myself'**
  String get slightProblemsWashing;

  /// Moderate problems washing option
  ///
  /// In en, this message translates to:
  /// **'I have moderate problems washing or dressing myself'**
  String get moderateProblemsWashing;

  /// Severe problems washing option
  ///
  /// In en, this message translates to:
  /// **'I have severe problems washing or dressing myself'**
  String get severeProblemsWashing;

  /// Unable to wash option
  ///
  /// In en, this message translates to:
  /// **'I am unable to wash or dress myself'**
  String get unableToWash;

  /// No problems usual activities option
  ///
  /// In en, this message translates to:
  /// **'I have no problems doing my usual activities'**
  String get noProblemsUsualActivities;

  /// Slight problems usual activities option
  ///
  /// In en, this message translates to:
  /// **'I have slight problems doing my usual activities'**
  String get slightProblemsUsualActivities;

  /// Moderate problems usual activities option
  ///
  /// In en, this message translates to:
  /// **'I have moderate problems doing my usual activities'**
  String get moderateProblemsUsualActivities;

  /// Severe problems usual activities option
  ///
  /// In en, this message translates to:
  /// **'I have severe problems doing my usual activities'**
  String get severeProblemsUsualActivities;

  /// Unable to do usual activities option
  ///
  /// In en, this message translates to:
  /// **'I am unable to do my usual activities'**
  String get unableToDoUsualActivities;

  /// No pain or discomfort option
  ///
  /// In en, this message translates to:
  /// **'I have no pain or discomfort'**
  String get noPainDiscomfort;

  /// Slight pain or discomfort option
  ///
  /// In en, this message translates to:
  /// **'I have slight pain or discomfort'**
  String get slightPainDiscomfort;

  /// Moderate pain or discomfort option
  ///
  /// In en, this message translates to:
  /// **'I have moderate pain or discomfort'**
  String get moderatePainDiscomfort;

  /// Severe pain or discomfort option
  ///
  /// In en, this message translates to:
  /// **'I have severe pain or discomfort'**
  String get severePainDiscomfort;

  /// Extreme pain or discomfort option
  ///
  /// In en, this message translates to:
  /// **'I have extreme pain or discomfort'**
  String get extremePainDiscomfort;

  /// Not anxious or depressed option
  ///
  /// In en, this message translates to:
  /// **'I am not anxious or depressed'**
  String get notAnxiousDepressed;

  /// Slightly anxious or depressed option
  ///
  /// In en, this message translates to:
  /// **'I am slightly anxious or depressed'**
  String get slightlyAnxiousDepressed;

  /// Moderately anxious or depressed option
  ///
  /// In en, this message translates to:
  /// **'I am moderately anxious or depressed'**
  String get moderatelyAnxiousDepressed;

  /// Severely anxious or depressed option
  ///
  /// In en, this message translates to:
  /// **'I am severely anxious or depressed'**
  String get severelyAnxiousDepressed;

  /// Extremely anxious or depressed option
  ///
  /// In en, this message translates to:
  /// **'I am extremely anxious or depressed'**
  String get extremelyAnxiousDepressed;

  /// Message when patient code is not set in chart widget
  ///
  /// In en, this message translates to:
  /// **'No patient code set'**
  String get noPatientCodeSet;

  /// Error message when LARS data fetch fails
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch LARS data: {error}'**
  String failedToFetchLarsData(String error);

  /// Message when no chart data is available
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get noDataAvailableYet;

  /// Vegetables food item name
  ///
  /// In en, this message translates to:
  /// **'Vegetables (all types)'**
  String get foodVegetablesAllTypes;

  /// Vegetables examples
  ///
  /// In en, this message translates to:
  /// **'Cabbage, broccoli, carrots, beets, cauliflower, zucchini, spinach'**
  String get foodVegetablesExamples;

  /// Root vegetables food item name
  ///
  /// In en, this message translates to:
  /// **'Root vegetables'**
  String get foodRootVegetables;

  /// Root vegetables examples
  ///
  /// In en, this message translates to:
  /// **'Potatoes with skin, carrots, parsnips, celery root'**
  String get foodRootVegetablesExamples;

  /// Whole grains food item name
  ///
  /// In en, this message translates to:
  /// **'Whole grains'**
  String get foodWholeGrains;

  /// Whole grains examples
  ///
  /// In en, this message translates to:
  /// **'Oatmeal, buckwheat, pearl barley, brown rice, quinoa'**
  String get foodWholeGrainsExamples;

  /// Whole grain bread food item name
  ///
  /// In en, this message translates to:
  /// **'Whole grain bread'**
  String get foodWholeGrainBread;

  /// Whole grain bread examples
  ///
  /// In en, this message translates to:
  /// **'Black bread, bran bread, whole grain bread'**
  String get foodWholeGrainBreadExamples;

  /// Nuts and seeds food item name
  ///
  /// In en, this message translates to:
  /// **'Nuts and seeds'**
  String get foodNutsAndSeeds;

  /// Nuts and seeds examples
  ///
  /// In en, this message translates to:
  /// **'Almonds, walnuts, hazelnuts, seeds, flax seeds, chia'**
  String get foodNutsAndSeedsExamples;

  /// Legumes food item name
  ///
  /// In en, this message translates to:
  /// **'Legumes'**
  String get foodLegumes;

  /// Legumes examples
  ///
  /// In en, this message translates to:
  /// **'Beans (any), lentils, chickpeas, peas (including soups)'**
  String get foodLegumesExamples;

  /// Fruits with skin food item name
  ///
  /// In en, this message translates to:
  /// **'Fruits with skin'**
  String get foodFruitsWithSkin;

  /// Fruits with skin examples
  ///
  /// In en, this message translates to:
  /// **'Apples, pears, plums, apricots (if skin eaten)'**
  String get foodFruitsWithSkinExamples;

  /// Berries food item name
  ///
  /// In en, this message translates to:
  /// **'Berries (any)'**
  String get foodBerriesAny;

  /// Berries examples
  ///
  /// In en, this message translates to:
  /// **'Raspberries, strawberries, blueberries, currants, blackberries'**
  String get foodBerriesExamples;

  /// Soft fruits without skin food item name
  ///
  /// In en, this message translates to:
  /// **'Soft fruits without skin'**
  String get foodSoftFruitsWithoutSkin;

  /// Soft fruits examples
  ///
  /// In en, this message translates to:
  /// **'Bananas, melon, watermelon, mango'**
  String get foodSoftFruitsExamples;

  /// Muesli and bran cereals food item name
  ///
  /// In en, this message translates to:
  /// **'Muesli and bran cereals'**
  String get foodMuesliAndBranCereals;

  /// Muesli examples
  ///
  /// In en, this message translates to:
  /// **'Sugar-free muesli, bran cereals, granola'**
  String get foodMuesliExamples;

  /// Water drink item name
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get drinkWater;

  /// Water examples
  ///
  /// In en, this message translates to:
  /// **'Plain water, mineral water, filtered water'**
  String get drinkWaterExamples;

  /// Coffee drink item name
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get drinkCoffee;

  /// Coffee examples
  ///
  /// In en, this message translates to:
  /// **'Espresso, cappuccino, americano, latte'**
  String get drinkCoffeeExamples;

  /// Tea drink item name
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get drinkTea;

  /// Tea examples
  ///
  /// In en, this message translates to:
  /// **'Black tea, green tea, herbal tea, chamomile'**
  String get drinkTeaExamples;

  /// Alcohol drink item name
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get drinkAlcohol;

  /// Alcohol examples
  ///
  /// In en, this message translates to:
  /// **'Beer, wine, spirits, cocktails'**
  String get drinkAlcoholExamples;

  /// Carbonated drinks item name
  ///
  /// In en, this message translates to:
  /// **'Carbonated drinks'**
  String get drinkCarbonatedDrinks;

  /// Carbonated drinks examples
  ///
  /// In en, this message translates to:
  /// **'Cola, sprite, fanta, sparkling water'**
  String get drinkCarbonatedExamples;

  /// Juices drink item name
  ///
  /// In en, this message translates to:
  /// **'Juices'**
  String get drinkJuices;

  /// Juices examples
  ///
  /// In en, this message translates to:
  /// **'Orange juice, apple juice, grape juice, smoothies'**
  String get drinkJuicesExamples;

  /// Dairy drinks item name
  ///
  /// In en, this message translates to:
  /// **'Dairy drinks'**
  String get drinkDairyDrinks;

  /// Dairy drinks examples
  ///
  /// In en, this message translates to:
  /// **'Milk, kefir, yogurt drinks, milkshakes'**
  String get drinkDairyExamples;

  /// Energy drinks item name
  ///
  /// In en, this message translates to:
  /// **'Energy drinks'**
  String get drinkEnergyDrinks;

  /// Energy drinks examples
  ///
  /// In en, this message translates to:
  /// **'Red Bull, Monster, energy shots'**
  String get drinkEnergyExamples;

  /// Servings unit
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get unitServings;

  /// Slices unit
  ///
  /// In en, this message translates to:
  /// **'slices'**
  String get unitSlices;

  /// Handfuls unit
  ///
  /// In en, this message translates to:
  /// **'handfuls'**
  String get unitHandfuls;

  /// Pieces unit
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get unitPieces;

  /// Glasses unit
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get unitGlasses;

  /// Cups unit
  ///
  /// In en, this message translates to:
  /// **'cups'**
  String get unitCups;

  /// Drinks unit
  ///
  /// In en, this message translates to:
  /// **'drinks'**
  String get unitDrinks;

  /// Cans unit
  ///
  /// In en, this message translates to:
  /// **'cans'**
  String get unitCans;

  /// Daily notification title
  ///
  /// In en, this message translates to:
  /// **'Time to fill questionnaire'**
  String get notificationTitle;

  /// Daily notification body text
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to fill out today\'s questionnaire'**
  String get notificationBody;

  /// VAS title
  ///
  /// In en, this message translates to:
  /// **'YOUR HEALTH TODAY'**
  String get healthTodayTitle;

  /// VAS description
  ///
  /// In en, this message translates to:
  /// **'We would like to know how good or bad your health is TODAY. This scale is numbered from 0 to 100. 100 means the best health you can imagine. 0 means the worst health you can imagine.'**
  String get healthTodayDescription;

  /// Label before numeric value
  ///
  /// In en, this message translates to:
  /// **'YOUR HEALTH TODAY ='**
  String get yourHealthTodayIs;

  /// Legal: Terms of Use title
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// Legal: Privacy Policy title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Placeholder text for Terms of Use
  ///
  /// In en, this message translates to:
  /// **'Coming soon: Terms of Use content will appear here.'**
  String get termsOfUseComingSoon;

  /// Placeholder text for Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'Coming soon: Privacy Policy content will appear here.'**
  String get privacyPolicyComingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'lt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'lt':
      return AppLocalizationsLt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
