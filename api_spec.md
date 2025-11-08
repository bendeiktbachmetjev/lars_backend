# API Specification (Draft)

| Endpoint         | Method | Description                | Request Example         | Response Example        |
|------------------|--------|----------------------------|------------------------|-------------------------|
| /login           | POST   | Patient login by code      | { "patient_code": "123456" } | { "token": "...", "patient_code": "123456" } |
| /sendDaily       | POST   | Send daily symptom entry   | { "token": "...", "date": "2024-06-01", "data": { ... } } | { "status": "ok" } |
| /sendWeekly      | POST   | Send weekly LARS score     | { "token": "...", "date": "2024-06-01", "data": { ... } } | { "status": "ok" } |
| /sendMonthly     | POST   | Send monthly QoL           | { "token": "...", "date": "2024-06-01", "data": { ... } } | { "status": "ok" } |
| /history         | GET    | Get last N entries         | /history?period=7&token=... | { "entries": [ ... ] } |

## Notes
- All endpoints require a valid token (except /login)
- Data format for forms will be specified later
- This is a draft, endpoints may change 