# DownHub

- `backend/` — a small Node.js / Express resolver service.
- `lib/` — a Flutter app built with BLoC + Clean Architecture following the
  "DownHub" design system (see `design.md`).

> **Scope constraint (by design):** the system only supports direct media
> URLs (e.g. `.mp4`, `.mov`, `.webm`) and public HLS/DASH manifests
> (`.m3u8`, `.mpd`). It does **not** scrape TikTok, YouTube, Instagram, etc.

## 1. Backend

```bash
cd backend
npm install
npm run dev     # http://localhost:4000
```

Quick test:

```bash
curl -X POST http://localhost:4000/resolve \
  -H "Content-Type: application/json" \
  -d '{"url":"https://download.samplelib.com/mp4/sample-5s.mp4"}'
```

See `backend/README.md` for the full API and error-code reference.

## 2. Flutter app

```bash
flutter pub get
flutter run
```

### Pointing the app at your backend

`lib/core/constants/api_constants.dart`:

- Android emulator → `http://10.0.2.2:4000` (default)
- iOS simulator → `http://localhost:4000`
- Physical device → `http://<your-LAN-IP>:4000` (and ensure the backend
  listens on `0.0.0.0`).

Cleartext HTTP is enabled in `AndroidManifest.xml` and `Info.plist` for
local dev; disable for production and point at an HTTPS host.

## 3. Architecture

```
lib/
  core/
    constants/    api + app-wide constants
    error/        exceptions, failures, Dio → domain mapper
    network/      DioClient (retry + logging), NetworkInfo
    theme/        Luminescent Vault palette + ThemeData
    usecases/     UseCase<T, Params> + Either
    utils/        UrlValidator, FileSizeFormatter
  features/
    download_video/
      data/       datasources, models, repository impl
      domain/     entities, repository contract, use cases
      presentation/ bloc, pages, widgets
    downloads_library/
      data/       local datasource (SharedPreferences + files), repo impl
      domain/     entities, repo contract, use cases
      presentation/ bloc, pages, widgets
  shell/          AppShell with bottom navigation
  app.dart        MultiBlocProvider + MaterialApp
  injection_container.dart   get_it wiring
  main.dart       entry point
```

### Rules enforced by the layout

- UI never calls Dio / SharedPreferences / `share_plus` directly.
- BLoCs depend on **use cases** only.
- Use cases depend on **repository contracts** (domain).
- Repositories are the only place where exceptions → `Failure` mapping
  happens.
- All wiring is centralised in `injection_container.dart`.

### Key packages

| Concern         | Package           |
|-----------------|-------------------|
| State           | `flutter_bloc`    |
| DI              | `get_it`          |
| HTTP            | `dio`             |
| Connectivity    | `connectivity_plus` |
| File paths      | `path_provider`   |
| Local metadata  | `shared_preferences` |
| Sharing         | `share_plus`      |
| Fonts           | `google_fonts`    |
| IDs             | `uuid`            |
| Dates           | `intl`            |

## 4. Error handling

| Scenario                     | Surface                                             |
|------------------------------|-----------------------------------------------------|
| Empty / non-http URL         | Inline error under the button                        |
| No internet                  | "No internet connection. Check your network…"        |
| Upstream timeout             | "The server took too long to respond…"               |
| Not a video (HTML, etc.)     | "This link does not point to a downloadable video…"  |
| File write / cache error     | `CacheFailure` message                               |
| Any other Dio / server error | `ServerFailure` with server-provided message         |

The mapping chain is:

`DioException` → `DioExceptionMapper` → typed `Exception` → repository
catches it → `Failure` → BLoC converts to a user-friendly message.

## 5. Testing

```bash
flutter test
```

Currently includes sanity tests for `UrlValidator` and `FileSizeFormatter`.

## 6. Bonus features included

- Download progress tracking via Dio's `onReceiveProgress`, surfaced by the
  `ProgressTick` event in `DownloadBloc` and rendered as a glowing pulse
  bar (per the design system).
- Structured logging in the backend (`utils/logger.js`) with ISO
  timestamps, levels, and optional `DEBUG=true` opt-in.
- Modular backend split (`routes/` → `middleware/` → `services/` →
  `utils/`) so the resolver can be extended without touching Express
  wiring.
