// App runtime configuration
// Use: flutter run --dart-define=API_BASE_URL=https://your-backend
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000', // Android Emulator default; iOS Simulator can use http://127.0.0.1:8000
);


