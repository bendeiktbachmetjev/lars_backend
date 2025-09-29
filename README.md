### Backend deploy (Railway)

1) Create a new empty GitHub repo and provide the remote URL
2) Initialize git and push this project
```
cd /Users/benediktbachmetjev/StudioProjects/lars_app
git init
git add .
git commit -m "Initial commit: backend + frontend"
git branch -M main
git remote add origin <YOUR_GITHUB_REPO_URL>
git push -u origin main
```
3) In Railway: New Project → Deploy from GitHub → select this repo → set root to `backend/`
4) Railway will build using `backend/Dockerfile`
5) Set Variables:
   - `DATABASE_URL` → your Supabase pooler URI with `sslmode=require`
   - (optional) `SUPABASE_SSLMODE=require`
6) After deploy, open the service URL and check `/healthz`

### Mobile build with remote API
Use dart-define to set API base:
```
flutter build apk --dart-define=API_BASE_URL=https://<railway-host>
flutter build ipa --dart-define=API_BASE_URL=https://<railway-host>
```

# Lars App

Lars App is a mobile application for post-surgery patients to track their well-being and share data with their doctor.

## Description
Patients fill out daily, weekly, and monthly questionnaires about their condition. The doctor can see the patient's progress and analytics via a separate web dashboard.

## Main Features
- Authentication by patient code
- Daily, weekly, and monthly questionnaires
- Reminders to fill out forms
- Mini-analytics on the main screen
- Secure data storage and transmission

## Project Structure
- `main.dart` — Flutter app entry point
- `models/` — data models
- `services/` — API and storage logic
- `screens/` — app screens
- `widgets/` — reusable widgets

## How to Run
1. Open the project in Android Studio or Xcode
2. Run `flutter pub get`
3. Launch on an emulator or device

## Documentation
- API specification: see `api_spec.md`
- ER diagram: see the "Data Structure" section below

---

# English summary
Lars App is a mobile app for post-surgery patients to track their health and share data with their doctor. Patients fill daily, weekly, and monthly forms; doctors see the progress via a web dashboard. 