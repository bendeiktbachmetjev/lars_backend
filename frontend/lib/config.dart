// App runtime configuration
// Use: flutter run --dart-define=API_BASE_URL=https://your-backend
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  // Default to Railway backend. You can override at build time with --dart-define
  defaultValue: 'https://larsbackend-production.up.railway.app',
);


