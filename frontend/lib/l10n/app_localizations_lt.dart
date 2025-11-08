// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appTitle => 'iLARS';

  @override
  String get appName => 'iLARS';

  @override
  String get dashboard => 'Suvestinė';

  @override
  String get profile => 'Profilis';

  @override
  String get statistics => 'Statistika';

  @override
  String get weekly => 'Savaitės';

  @override
  String get monthly => 'Mėnesio';

  @override
  String get yearly => 'Metų';

  @override
  String get todaysQuestionnaire => 'Šiandienos klausimynas';

  @override
  String get dailyQuestionnaire => 'Kasdieninis klausimynas';

  @override
  String get weeklyQuestionnaire => 'Savaitės klausimynas (LARS)';

  @override
  String get monthlyQuestionnaire => 'Mėnesio klausimynas';

  @override
  String get qualityOfLifeQuestionnaire =>
      'Gyvenimo kokybės klausimynas (EQ-5D-5L)';

  @override
  String get noQuestionnaireNeeded => 'Klausimynas nereikalingas';

  @override
  String get allQuestionnairesUpToDate => 'Visi klausimynai užpildyti';

  @override
  String get fillItNow => 'Užpildyti dabar';

  @override
  String get pleaseSetPatientCode =>
      'Prašome nustatyti paciento kodą Profilyje';

  @override
  String get failedToLoadQuestionnaireInfo =>
      'Nepavyko įkelti klausimyno informacijos';

  @override
  String get retry => 'Bandyti dar kartą';

  @override
  String get completeWeeklyQuestionnairesToSeeStatistics =>
      'Užbaikite savaitinius klausimynus, kad pamatytumėte savo LARS balo statistiką';

  @override
  String get completeMoreWeeklyQuestionnaires =>
      'Užbaikite daugiau savaitinių klausimynų, kad pamatytumėte LARS rodyklio tendencijas';

  @override
  String get ilarsPatient => 'iLARS pacientas';

  @override
  String get noPatientCode => 'Paciento kodo nėra';

  @override
  String code(String code) {
    return 'Kodas: $code';
  }

  @override
  String get patientCode => 'Paciento kodas';

  @override
  String get enterYourCode => 'Įveskite savo kodą';

  @override
  String get save => 'Išsaugoti';

  @override
  String get logout => 'Atsijungti';

  @override
  String get patientCodeSaved => 'Paciento kodas išsaugotas';

  @override
  String get patientCodeCleared => 'Paciento kodas išvalytas';

  @override
  String get dailySymptoms => 'Kasdieniniai simptomai';

  @override
  String get stoolPerDay => 'Tuštinimasis per dieną';

  @override
  String get padsUsed => 'Naudoti įklotai';

  @override
  String get urgent => 'Staigus noras tuštintis';

  @override
  String get nightStools => 'Tuštinimasis naktį';

  @override
  String get yes => 'Taip';

  @override
  String get no => 'Ne';

  @override
  String get stoolLeakage => 'Išmatų nelaikymas';

  @override
  String get none => 'Nėra';

  @override
  String get liquid => 'Skystos';

  @override
  String get solid => 'Kietos';

  @override
  String get incompleteEvacuation => 'Nepilnas pasituštinimas';

  @override
  String get bloating => 'Pilvo pūtimas';

  @override
  String get impactOnLife => 'Poveikis gyvenimui';

  @override
  String get whatDidYouConsumeToday => 'Ką jūs šiandien suvalgėte?';

  @override
  String get whatDidYouDrinkToday => 'Vartoti gėrimai';

  @override
  String quantity(String unit) {
    return 'Kiekis ($unit):';
  }

  @override
  String get stoolConsistency => 'Išmatų konsistencija';

  @override
  String get submit => 'Pateikti';

  @override
  String get submittedSuccessfully => 'Pateikta sėkmingai';

  @override
  String submitFailed(int statusCode) {
    return 'Pateikimas nepavyko: $statusCode';
  }

  @override
  String error(String error) {
    return 'Klaida: $error';
  }

  @override
  String get larsScoreQuestionnaire => 'LARS balo klausimynas';

  @override
  String get flatusControlQuestion =>
      'Ar kada nors yra buvę, kad negalėjote kontroliuoti dujų susikaupimą (pagadinti orą )?';

  @override
  String get liquidStoolLeakageQuestion =>
      'Ar kada nors turėjote atsitiktinį vandeningo išsituštinimo pratekėjimą?';

  @override
  String get bowelFrequencyQuestion => 'Kaip dažnai tuštinatės?';

  @override
  String get repeatBowelOpeningQuestion =>
      'Ar kada nors tuštinotės vėl, nepraėjus valandai po paskutinio tuštinimosi?';

  @override
  String get urgencyToToiletQuestion =>
      'Ar kada nors turėjote labai skubų poreikį tuštintis, kad privalėjote bėgti į tualetą?';

  @override
  String get totalScore => 'Bendras balas:';

  @override
  String get noNever => 'Ne, niekada';

  @override
  String get yesLessThanOncePerWeek => 'Taip, rečiau nei kartą per savaitę';

  @override
  String get yesAtLeastOncePerWeek => 'Taip, bent kartą per savaitę';

  @override
  String get moreThan7TimesPerDay =>
      'Daugiau nei 7 kartus per dieną (24 valandos)';

  @override
  String timesPerDay(String min, String max) {
    return '$min-$max kartai per dieną (24 valandos)';
  }

  @override
  String get lessThanOncePerDay => 'Rečiau nei kartą per dieną (24 valandos)';

  @override
  String get monthlyQualityOfLife => 'Mėnesio gyvenimo kokybė ';

  @override
  String get avoidTraveling => 'Aš vengiu kelionių dėl žarnyno problemų';

  @override
  String get avoidSocialActivities => 'Aš vengiu socialinių veiklų';

  @override
  String get feelEmbarrassed => 'Aš jaučiuosi gėdingai dėl savo būklės';

  @override
  String get worryOthersNotice => 'Aš bijau, kad kiti pastebės mano simptomus';

  @override
  String get feelDepressed => 'Aš jaučiuosi prislėgtas dėl žarnyno funkcijos';

  @override
  String get feelInControl =>
      'Aš jaučiuosi, kad kontroliuoju savo žarnyno simptomus';

  @override
  String get overallSatisfaction => 'Bendras pasitenkinimas žarnyno funkcija';

  @override
  String get eq5d5lQuestionnaire => 'EQ-5D-5L klausimynas';

  @override
  String get mobility => '1. JUDĖJIMAS';

  @override
  String get selfCare => '2. SAVĘS PRIEŽIŪRA';

  @override
  String get usualActivities => 'ĮPRASTA VEIKLA';

  @override
  String get usualActivitiesDescription =>
      'ĮPRASTA VEIKLA\n(pvz., darbas, mokslas, namų ruoša, šeimos ar laisvalaikio veiklos)';

  @override
  String get painDiscomfort => 'SKAUSMAS / DISKOMFORAS';

  @override
  String get anxietyDepression => 'NERIMAS / DEPRESIJA';

  @override
  String get noProblemsWalking => 'Man vaikščioti nesunku';

  @override
  String get slightProblemsWalking => 'Man vaikščioti sunkoka';

  @override
  String get moderateProblemsWalking => 'Man vaikščioti vidutiniškai sunku';

  @override
  String get severeProblemsWalking => 'Man vaikščioti labai sunku';

  @override
  String get unableToWalk => 'Aš negaliu vaikščioti';

  @override
  String get noProblemsWashing =>
      'Man visiškai lengva nusiprausti ar apsirengti';

  @override
  String get slightProblemsWashing => 'Man sunkoka nusiprausti ar apsirengti';

  @override
  String get moderateProblemsWashing =>
      'Man vidutiniškai sunku nusiprausti ar apsirengti';

  @override
  String get severeProblemsWashing =>
      'Man labai sunku nusiprausti ar apsirengti';

  @override
  String get unableToWash => 'Aš nesugebu nusiprausti ar apsirengti';

  @override
  String get noProblemsUsualActivities =>
      'Man visiškai lengva užsiimti savo įprasta veikla';

  @override
  String get slightProblemsUsualActivities =>
      'Man sunkoka užsiimti savo įprasta veikla';

  @override
  String get moderateProblemsUsualActivities =>
      'Man vidutiniškai sunku užsiimti savo įprasta veikla';

  @override
  String get severeProblemsUsualActivities =>
      'Man labai sunku užsiimti savo įprasta veikla';

  @override
  String get unableToDoUsualActivities =>
      'Aš nesugebu užsiimti savo įprasta veikla';

  @override
  String get noPainDiscomfort => 'Aš nejaučiu skausmo ar diskomforto';

  @override
  String get slightPainDiscomfort =>
      'Aš jaučiu šiokį tokį skausmą ar diskomfortą';

  @override
  String get moderatePainDiscomfort =>
      'Aš jaučiu vidutinišką skausmą ar diskomfortą';

  @override
  String get severePainDiscomfort => 'Aš jaučiu smarkų skausmą ar diskomfortą';

  @override
  String get extremePainDiscomfort =>
      'Aš jaučiu nepaprastą skausmą ar diskomfortą';

  @override
  String get notAnxiousDepressed =>
      'Nesu sunerimęs (-usi) ar apimtas (-a) depresijos';

  @override
  String get slightlyAnxiousDepressed =>
      'Esu šiek tiek sunerimęs (-usi) ar apimtas (-a) depresijos';

  @override
  String get moderatelyAnxiousDepressed =>
      'Esu vidutiniškai sunerimęs (-usi) ar apimtas (-a) depresijos';

  @override
  String get severelyAnxiousDepressed =>
      'Esu smarkiai sunerimęs (-usi) ar apimtas (-a) depresijos';

  @override
  String get extremelyAnxiousDepressed =>
      'Esu nepaprastai sunerimęs (-usi) ar apimtas (-a) depresijos';

  @override
  String get noPatientCodeSet => 'Paciento kodas nenustatytas';

  @override
  String failedToFetchLarsData(String error) {
    return 'Nepavyko gauti LARS duomenų: $error';
  }

  @override
  String get noDataAvailableYet => 'Duomenų dar nėra';

  @override
  String get foodVegetablesAllTypes => 'Daržovės (visų tipų)';

  @override
  String get foodVegetablesExamples =>
      'Kopūstai, brokoliai, morkos, žiediniai kopūstai, cukinijos, špinatai';

  @override
  String get foodRootVegetables => 'Šakninės daržovės';

  @override
  String get foodRootVegetablesExamples => 'Bulvės su žievele, morkos, šakniai';

  @override
  String get foodWholeGrains => 'Pilno grūdo produktai';

  @override
  String get foodWholeGrainsExamples =>
      'Avižiniai dribsniai, grikiai, rudieji ryžiai, bolivinės balandos';

  @override
  String get foodWholeGrainBread => 'Pilno grūdo duona';

  @override
  String get foodWholeGrainBreadExamples => 'Juoda duona, pilno grūdo duona';

  @override
  String get foodNutsAndSeeds => 'Riešutai ir sėklos';

  @override
  String get foodNutsAndSeedsExamples => 'Riešutai, sėklos, lino sėklos, chia';

  @override
  String get foodLegumes => 'Ankštiniai';

  @override
  String get foodLegumesExamples =>
      'Pupelės (bet kokios), lęšiai, žirneliai (įskaitant sriubas)';

  @override
  String get foodFruitsWithSkin => 'Vaisiai su žievele';

  @override
  String get foodFruitsWithSkinExamples =>
      'Obuoliai, kriaušės, slyvos, abrikosai (jei valgoma žievė)';

  @override
  String get foodBerriesAny => 'Uogos (bet kokios)';

  @override
  String get foodBerriesExamples =>
      'Avietės, braškės, mėlynės, serbentai, gervuogės';

  @override
  String get foodSoftFruitsWithoutSkin => 'Minkšti vaisiai be žievės';

  @override
  String get foodSoftFruitsExamples => 'Bananos, melionas, arbūzas, mangas';

  @override
  String get foodMuesliAndBranCereals => 'Mišrainės ir dribsniai';

  @override
  String get foodMuesliExamples => 'Cukraus neturintys dribsniai, granola';

  @override
  String get drinkWater => 'Vanduo';

  @override
  String get drinkWaterExamples =>
      'Paprastas vanduo, mineralinis vanduo, filtruotas vanduo';

  @override
  String get drinkCoffee => 'Kava';

  @override
  String get drinkCoffeeExamples => 'Espreso, kapučino, amerikano, latte';

  @override
  String get drinkTea => 'Arbata';

  @override
  String get drinkTeaExamples =>
      'Juoda arbata, žalia arbata, žolelių arbata, ramunėlių arbata';

  @override
  String get drinkAlcohol => 'Alkoholis';

  @override
  String get drinkAlcoholExamples => 'Alus, vynas, degtinė, kokteiliai';

  @override
  String get drinkCarbonatedDrinks => 'Gazuoti gėrimai';

  @override
  String get drinkCarbonatedExamples => 'Kola, sprite, fanta, gazuotas vanduo';

  @override
  String get drinkJuices => 'Sultys';

  @override
  String get drinkJuicesExamples =>
      'Apelsinų sultys, obuolių sultys, vynuogių sultys, smoothies';

  @override
  String get drinkDairyDrinks => 'Pieno gėrimai';

  @override
  String get drinkDairyExamples =>
      'Pienas, kefyras, jogurtas, pieno kokteiliai';

  @override
  String get drinkEnergyDrinks => 'Energetiniai gėrimai';

  @override
  String get drinkEnergyExamples => 'Red Bull, Monster, energy shots';

  @override
  String get unitServings => 'porcijos';

  @override
  String get unitSlices => 'riekeliai';

  @override
  String get unitHandfuls => 'kaušeliai';

  @override
  String get unitPieces => 'vnt';

  @override
  String get unitGlasses => 'inės';

  @override
  String get unitCups => 'puodeliai';

  @override
  String get unitDrinks => 'gėrimai';

  @override
  String get unitCans => 'skardinės';

  @override
  String get notificationTitle => 'Laikas užpildyti klausimyną';

  @override
  String get notificationBody => 'Nepamirškite užpildyti šiandienos klausimyno';

  @override
  String get healthTodayTitle => 'JŪSŲ SVEIKATA ŠIANDIEN';

  @override
  String get healthTodayDescription =>
      'Norėtume žinoti, kiek gera ar bloga jūsų sveikata ŠIANDIEN. Ši skalė sunumeruota nuo 0 iki 100. 100 reiškia geriausią sveikatą, kokią tik galite įsivaizduoti. 0 reiškia blogiausią sveikatą, kokią tik galite įsivaizduoti.';

  @override
  String get yourHealthTodayIs => 'JŪSŲ SVEIKATA ŠIANDIEN =';

  @override
  String get termsOfUse => 'Naudojimosi sąlygos';

  @override
  String get privacyPolicy => 'Privatumo politika';

  @override
  String get termsOfUseComingSoon =>
      'Netrukus: čia bus pateiktas Naudojimosi sąlygų turinys.';

  @override
  String get privacyPolicyComingSoon =>
      'Netrukus: čia bus pateiktas Privatumo politikos turinys.';
}
