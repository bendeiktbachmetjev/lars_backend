Ниже — целостное описание пользовательского и технического флоу приложения, оформленное так, чтобы его можно было сразу вставить в Cursor AI как «истину», на основе которой генерировать код и архитектуру.

⸻

1. Участники процесса
	•	Врач
Создаёт профиль пациента в веб-кабинете, заполняет мед-данные (возраст, пол, дата и тип операции, наличие стомы, сопутствующая терапия) и генерирует уникальный Patient Code.
	•	Пациент
Устанавливает мобильное приложение, вводит полученный Patient Code и заполняет опросники.
	•	Сервер
Хранит данные, сопоставляя их только с Patient Code. Пациент остаётся анонимным.

⸻

2. Онбординг пациента (один раз)
	1.	Экран «Ввести код».
	2.	Проверка кода через POST /login.
	3.	Если успех → сохранить токен и Patient Code локально, перейти на Dashboard.
	4.	Запросить разрешение на push-уведомления и локальные напоминания.
	5.	Создать локальный ежевечерний таймер (19:00 по часовому поясу устройства) с текстом «Заполните опросник за сегодня».

⸻

3. Логика выбора опросника «на сегодня»

today = now().date
if today == nextMonthlyDate(code):
    show Monthly QoL
elif today == nextWeeklyDate(code):
    show Weekly LARS
else:
    show Daily Diary

	•	Daily Diary — по умолчанию.
	•	Weekly LARS — заменяет дневник 1 раз в 7 дней, отсчёт начинается от даты первого заполнения Weekly.
	•	Monthly QoL — заменяет Weekly 1 раз в 30 дней, отсчёт от первого Monthly.
	•	После отправки анкеты сохраняем submitted_at и пересчитываем даты следующего Weekly/Monthly.

⸻

4. Поток «Один день жизни приложения»
	1.	19:00: срабатывает локальный пуш.
	2.	Пользователь открывает приложение → Dashboard.
	3.	Загружается карточка «Сегодняшний опросник» (тип определяется алгоритмом выше).
	4.	Пользователь заполняет форму → POST /sendDailySymptoms, /sendWeeklyLars или /sendMonthlyQoL (все запросы содержат поле patient_code).
	5.	На сервере данные кладутся в коллекцию, индексированную по patient_code и дате.
	6.	UI показывает «Спасибо» + мини-график тренда (например, последняя неделя количества дефекаций).

⸻

5. Структура UI

┌──────── App ────────┐
│ TabBar              │
│ ├ Dashboard         │  ← главный экран
│ │ ├ Card: Заполнить │
│ │ ├ Сводка графиков │
│ └ Profile           │  ← мед. данные readonly
└─────────────────────┘

	•	Dashboard
	•	Карточка «Заполнить {Daily/Weekly/Monthly}»
	•	Sparkline-графики последних значений (рисуются локально по кэш-данным).
	•	Profile
	•	Нередактируемое: возраст, пол, тип операции, дата.

⸻

6. Сетевые эндпоинты (минимум)

Method & Path	Body	Ответ
POST /login	{ code }	{ token }
POST /sendDaily	{ token, payload: DailySymptomEntry }	204
POST /sendWeekly	{ token, payload: WeeklyLarsScore }	204
POST /sendMonthly	{ token, payload: MonthlyQualityOfLife }	204

Сервер не рассылает данные в приложение; врач смотрит их через собственный интерфейс.

⸻

7. Модели данных (Dart)

class UserProfile {
  final String code;
  final String gender;
  final DateTime birthDate;
  final String surgeryType;
  final DateTime surgeryDate;
  final bool stoma;
  // readonly в приложении
}

class DailySymptomEntry {
  final DateTime date;
  final int stoolCount;
  final bool urgency;
  final StoolLeakage leakage;   // enum
  final bool nightStools;
  final int bloating;           // 0..10
  final bool incompleteEvac;
  final int padsUsed;           // 0 if none
  final int impactScore;        // 0..10
  final int bristolScale;       // 1..7
}

class WeeklyLarsScore { ... }

class MonthlyQualityOfLife { ... }


⸻

8. Алгоритм напоминаний
	•	Локальный: один фиксированный ежедневный flutter_local_notifications в 19:00.
	•	При открытии приложения проверяем, не заполнил ли пользователь сегодня; если нет, показываем Badge «1».
	•	Опционально: сервер может прислать push (FCM) в 19:00, но для MVP достаточно локального.

⸻

9. Безопасность и анонимность
	•	Приложение хранит только patient_code и JWT-token.
	•	Персональные данные находятся только у врача.
	•	Трафик — HTTPS, TLS 1.3.
	•	При утере телефона пациент вводит код заново, данные подтягиваются заново (опционально можно хранить историю локально под паролем).

⸻

10. Мини-дорожная карта разработки
	1.	Flutter scaffold (+ CI/CD, Android & iOS targets).
	2.	Data models & local storage (Hive/Isar).
	3.	Auth flow по коду (Firebase Functions или Supabase RPC).
	4.	UI Dashboard + формы всех 3 опросников.
	5.	Локальные нотификации.
	6.	POST-эндпоинты и простая БД (Supabase/Postgres).
	7.	Графики (fl_chart) и базовая аналитика во врачи-портале (веб-таблица Supabase).

⸻

Эта структура описывает полный пользовательский флоу, сетевое взаимодействие, модели данных и приоритеты разработки. Следующий логичный шаг — разбить пункт 3 «Auth flow по коду» на конкретные Flutter-виджеты и серверные функции, либо начать с миграций БД и схем.