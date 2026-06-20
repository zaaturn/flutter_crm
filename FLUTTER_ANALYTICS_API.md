# Flutter Analytics API

Django analytics module consumed by `lib/analytics/` (BLoC + shared `ApiClient` Dio).

## Access

- Menu visible when `is_superuser` OR `admin_modules["analytics"] == true`
- API **403** → "You don't have access to Analytics" (no logout)
- **401** → shared `ApiClient` refresh / session redirect

## Endpoints

| Tab | GET | Query |
|-----|-----|-------|
| Overview | `/api/analytics/overview/` | — |
| Weekly attendance | `/api/analytics/attendance/weekly/` | `year`, `week` (ISO, optional) |
| Weekly business | `/api/analytics/business/weekly/` | `year`, `week` |
| Monthly billing | `/api/analytics/billing/monthly/` | `year` |
| Leave (overview section) | `/api/analytics/leave/` | `year`, `month` |

## UI

- **Overview**: KPI cards + leave summary; pull-to-refresh
- **Attendance**: week picker, day dropdown (daily), Daily / Weekly summary subviews
- **Daily table**: Name, Date, Check-in, Check-out, **Hours** (`capped_hours` only), status badges
- **Business / Billing**: week or year filters, ₹ formatting via `AnalyticsMoney`
- Loading shimmer + error retry on all tabs

## Parsing notes

- Money: `"120000.00"` strings → ₹ display
- Times: `"09:15:00"` or ISO datetime → `hh:mm a`
- Do **not** cap hours in Flutter — use `capped_hours` / `total_capped_hours` from API

## Entry

- Desktop sidebar → Analytics
- Mobile admin grid → Analytics tile
- `AnalyticsFlowController.open(context)`
