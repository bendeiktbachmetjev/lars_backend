// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'iLARS';

  @override
  String get appName => 'iLARS';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get profile => 'Profile';

  @override
  String get statistics => 'Statistics';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get todaysQuestionnaire => 'Today\'s Questionnaire';

  @override
  String get dailyQuestionnaire => 'Daily Questionnaire';

  @override
  String get weeklyQuestionnaire => 'Weekly Questionnaire (LARS)';

  @override
  String get monthlyQuestionnaire => 'Monthly Questionnaire';

  @override
  String get qualityOfLifeQuestionnaire =>
      'Quality of Life Questionnaire (EQ-5D-5L)';

  @override
  String get noQuestionnaireNeeded => 'No questionnaire needed';

  @override
  String get allQuestionnairesUpToDate => 'All questionnaires are up to date';

  @override
  String get fillItNow => 'Fill It Now';

  @override
  String get pleaseSetPatientCode => 'Please set your patient code in Profile';

  @override
  String get failedToLoadQuestionnaireInfo =>
      'Failed to load questionnaire info';

  @override
  String get retry => 'Retry';

  @override
  String get completeWeeklyQuestionnairesToSeeStatistics =>
      'Complete weekly questionnaires to see your LARS score statistics';

  @override
  String get completeMoreWeeklyQuestionnaires =>
      'Complete more weekly questionnaires to see improvement trends';

  @override
  String get ilarsPatient => 'iLARS Patient';

  @override
  String get noPatientCode => 'No patient code';

  @override
  String code(String code) {
    return 'Code: $code';
  }

  @override
  String get patientCode => 'Patient Code';

  @override
  String get enterYourCode => 'Enter your code';

  @override
  String get save => 'Save';

  @override
  String get logout => 'Logout';

  @override
  String get patientCodeSaved => 'Patient code saved';

  @override
  String get patientCodeCleared => 'Patient code cleared';

  @override
  String get dailySymptoms => 'Daily Symptoms';

  @override
  String get stoolPerDay => 'Stool/day';

  @override
  String get padsUsed => 'Pads used';

  @override
  String get urgent => 'Urgent';

  @override
  String get nightStools => 'Night stools';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get stoolLeakage => 'Stool leakage';

  @override
  String get none => 'None';

  @override
  String get liquid => 'Liquid';

  @override
  String get solid => 'Solid';

  @override
  String get incompleteEvacuation => 'Incomplete evacuation';

  @override
  String get bloating => 'Bloating';

  @override
  String get impactOnLife => 'Impact on life';

  @override
  String get whatDidYouConsumeToday => 'What did you consume today?';

  @override
  String get whatDidYouDrinkToday => 'What did you drink today?';

  @override
  String quantity(String unit) {
    return 'Quantity ($unit):';
  }

  @override
  String get stoolConsistency => 'Stool Consistency';

  @override
  String get submit => 'Submit';

  @override
  String get submittedSuccessfully => 'Submitted successfully';

  @override
  String submitFailed(int statusCode) {
    return 'Submit failed: $statusCode';
  }

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get larsScoreQuestionnaire => 'LARS Score Questionnaire';

  @override
  String get flatusControlQuestion =>
      'Do you ever have occasions when you cannot control your flatus (wind)?';

  @override
  String get liquidStoolLeakageQuestion =>
      'Do you ever have any accidental leakage of liquid stool?';

  @override
  String get bowelFrequencyQuestion => 'How often do you open your bowels?';

  @override
  String get repeatBowelOpeningQuestion =>
      'Do you ever have to open your bowels again within one hour of the last bowel opening?';

  @override
  String get urgencyToToiletQuestion =>
      'Do you ever have such a strong urge to open your bowels that you have to rush to the toilet?';

  @override
  String get totalScore => 'Total Score:';

  @override
  String get noNever => 'No, never';

  @override
  String get yesLessThanOncePerWeek => 'Yes, less than once per week';

  @override
  String get yesAtLeastOncePerWeek => 'Yes, at least once per week';

  @override
  String get moreThan7TimesPerDay => 'More than 7 times per day (24 hours)';

  @override
  String timesPerDay(String min, String max) {
    return '$min-$max times per day (24 hours)';
  }

  @override
  String get lessThanOncePerDay => 'Less than once per day (24 hours)';

  @override
  String get monthlyQualityOfLife => 'Monthly Quality of Life ';

  @override
  String get avoidTraveling => 'I avoid traveling due to bowel problems';

  @override
  String get avoidSocialActivities => 'I avoid social activities';

  @override
  String get feelEmbarrassed => 'I feel embarrassed by my condition';

  @override
  String get worryOthersNotice => 'I worry others will notice my symptoms';

  @override
  String get feelDepressed => 'I feel depressed because of bowel function';

  @override
  String get feelInControl => 'I feel in control of my bowel symptoms';

  @override
  String get overallSatisfaction => 'Overall satisfaction with bowel function';

  @override
  String get eq5d5lQuestionnaire => 'EQ-5D-5L Questionnaire';

  @override
  String get mobility => 'MOBILITY';

  @override
  String get selfCare => 'SELF-CARE';

  @override
  String get usualActivities => 'USUAL ACTIVITIES';

  @override
  String get usualActivitiesDescription =>
      'USUAL ACTIVITIES\n(e.g. work, study, housework, family or leisure activities)';

  @override
  String get painDiscomfort => 'PAIN / DISCOMFORT';

  @override
  String get anxietyDepression => 'ANXIETY / DEPRESSION';

  @override
  String get noProblemsWalking => 'I have no problems in walking about';

  @override
  String get slightProblemsWalking => 'I have slight problems in walking about';

  @override
  String get moderateProblemsWalking =>
      'I have moderate problems in walking about';

  @override
  String get severeProblemsWalking => 'I have severe problems in walking about';

  @override
  String get unableToWalk => 'I am unable to walk about';

  @override
  String get noProblemsWashing =>
      'I have no problems washing or dressing myself';

  @override
  String get slightProblemsWashing =>
      'I have slight problems washing or dressing myself';

  @override
  String get moderateProblemsWashing =>
      'I have moderate problems washing or dressing myself';

  @override
  String get severeProblemsWashing =>
      'I have severe problems washing or dressing myself';

  @override
  String get unableToWash => 'I am unable to wash or dress myself';

  @override
  String get noProblemsUsualActivities =>
      'I have no problems doing my usual activities';

  @override
  String get slightProblemsUsualActivities =>
      'I have slight problems doing my usual activities';

  @override
  String get moderateProblemsUsualActivities =>
      'I have moderate problems doing my usual activities';

  @override
  String get severeProblemsUsualActivities =>
      'I have severe problems doing my usual activities';

  @override
  String get unableToDoUsualActivities =>
      'I am unable to do my usual activities';

  @override
  String get noPainDiscomfort => 'I have no pain or discomfort';

  @override
  String get slightPainDiscomfort => 'I have slight pain or discomfort';

  @override
  String get moderatePainDiscomfort => 'I have moderate pain or discomfort';

  @override
  String get severePainDiscomfort => 'I have severe pain or discomfort';

  @override
  String get extremePainDiscomfort => 'I have extreme pain or discomfort';

  @override
  String get notAnxiousDepressed => 'I am not anxious or depressed';

  @override
  String get slightlyAnxiousDepressed => 'I am slightly anxious or depressed';

  @override
  String get moderatelyAnxiousDepressed =>
      'I am moderately anxious or depressed';

  @override
  String get severelyAnxiousDepressed => 'I am severely anxious or depressed';

  @override
  String get extremelyAnxiousDepressed => 'I am extremely anxious or depressed';

  @override
  String get noPatientCodeSet => 'No patient code set';

  @override
  String failedToFetchLarsData(String error) {
    return 'Failed to fetch LARS data: $error';
  }

  @override
  String get noDataAvailableYet => 'No data available yet';

  @override
  String get foodVegetablesAllTypes => 'Vegetables (all types)';

  @override
  String get foodVegetablesExamples =>
      'Cabbage, broccoli, carrots, beets, cauliflower, zucchini, spinach';

  @override
  String get foodRootVegetables => 'Root vegetables';

  @override
  String get foodRootVegetablesExamples =>
      'Potatoes with skin, carrots, parsnips, celery root';

  @override
  String get foodWholeGrains => 'Whole grains';

  @override
  String get foodWholeGrainsExamples =>
      'Oatmeal, buckwheat, pearl barley, brown rice, quinoa';

  @override
  String get foodWholeGrainBread => 'Whole grain bread';

  @override
  String get foodWholeGrainBreadExamples =>
      'Black bread, bran bread, whole grain bread';

  @override
  String get foodNutsAndSeeds => 'Nuts and seeds';

  @override
  String get foodNutsAndSeedsExamples =>
      'Almonds, walnuts, hazelnuts, seeds, flax seeds, chia';

  @override
  String get foodLegumes => 'Legumes';

  @override
  String get foodLegumesExamples =>
      'Beans (any), lentils, chickpeas, peas (including soups)';

  @override
  String get foodFruitsWithSkin => 'Fruits with skin';

  @override
  String get foodFruitsWithSkinExamples =>
      'Apples, pears, plums, apricots (if skin eaten)';

  @override
  String get foodBerriesAny => 'Berries (any)';

  @override
  String get foodBerriesExamples =>
      'Raspberries, strawberries, blueberries, currants, blackberries';

  @override
  String get foodSoftFruitsWithoutSkin => 'Soft fruits without skin';

  @override
  String get foodSoftFruitsExamples => 'Bananas, melon, watermelon, mango';

  @override
  String get foodMuesliAndBranCereals => 'Muesli and bran cereals';

  @override
  String get foodMuesliExamples => 'Sugar-free muesli, bran cereals, granola';

  @override
  String get drinkWater => 'Water';

  @override
  String get drinkWaterExamples => 'Plain water, mineral water, filtered water';

  @override
  String get drinkCoffee => 'Coffee';

  @override
  String get drinkCoffeeExamples => 'Espresso, cappuccino, americano, latte';

  @override
  String get drinkTea => 'Tea';

  @override
  String get drinkTeaExamples => 'Black tea, green tea, herbal tea, chamomile';

  @override
  String get drinkAlcohol => 'Alcohol';

  @override
  String get drinkAlcoholExamples => 'Beer, wine, spirits, cocktails';

  @override
  String get drinkCarbonatedDrinks => 'Carbonated drinks';

  @override
  String get drinkCarbonatedExamples => 'Cola, sprite, fanta, sparkling water';

  @override
  String get drinkJuices => 'Juices';

  @override
  String get drinkJuicesExamples =>
      'Orange juice, apple juice, grape juice, smoothies';

  @override
  String get drinkDairyDrinks => 'Dairy drinks';

  @override
  String get drinkDairyExamples => 'Milk, kefir, yogurt drinks, milkshakes';

  @override
  String get drinkEnergyDrinks => 'Energy drinks';

  @override
  String get drinkEnergyExamples => 'Red Bull, Monster, energy shots';

  @override
  String get unitServings => 'servings';

  @override
  String get unitSlices => 'slices';

  @override
  String get unitHandfuls => 'handfuls';

  @override
  String get unitPieces => 'pieces';

  @override
  String get unitGlasses => 'glasses';

  @override
  String get unitCups => 'cups';

  @override
  String get unitDrinks => 'drinks';

  @override
  String get unitCans => 'cans';

  @override
  String get notificationTitle => 'Time to fill questionnaire';

  @override
  String get notificationBody =>
      'Don\'t forget to fill out today\'s questionnaire';

  @override
  String get healthTodayTitle => 'YOUR HEALTH TODAY';

  @override
  String get healthTodayDescription =>
      'We would like to know how good or bad your health is TODAY. This scale is numbered from 0 to 100. 100 means the best health you can imagine. 0 means the worst health you can imagine.';

  @override
  String get yourHealthTodayIs => 'YOUR HEALTH TODAY =';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUseComingSoon =>
      'Coming soon: Terms of Use content will appear here.';

  @override
  String get privacyPolicyComingSoon =>
      'Coming soon: Privacy Policy content will appear here.';
}
