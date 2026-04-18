# Luminescent Vault — Resolver Backend

A small Express service the Flutter app calls to turn a user-pasted URL into
a confirmed, directly-downloadable media URL.

## What it supports

| Input                                           | Path                     |
|-------------------------------------------------|--------------------------|
| Direct video file (`.mp4`, `.webm`, `.mov`, …)  | HTTP HEAD probe (fast)   |
| HLS / DASH manifest (`.m3u8`, `.mpd`)           | HTTP HEAD probe (fast)   |
| YouTube / Instagram / Facebook / TikTok / …     | `yt-dlp` fallback        |
| Anything else (a news article, login page, …)   | Rejected                 |

The resolver always tries the fast direct-HEAD path first, so plain CDN URLs
stay cheap. It only shells out to `yt-dlp` when the page isn't a media file.

## Install

```bash
cd backend
npm install
```

### Install yt-dlp (required for social media links)

`yt-dlp` is a separate binary and **must be on the backend host's `PATH`**.

**Windows (via winget):**
```powershell
winget install yt-dlp.yt-dlp
```

**macOS (via Homebrew):**
```bash
brew install yt-dlp
```

**Linux (via pipx / apt / pip):**
```bash
pipx install yt-dlp
# or
sudo apt install yt-dlp
```

**Verify:**
```bash
yt-dlp --version
```

`ffmpeg` is not required for the paths we use (we ask for pre-muxed
progressive streams only), but installing it anyway is a good idea.

If you don't want to install yt-dlp, set `YTDLP_DISABLED=true` and the
service will only support direct URLs.

## Run

```bash
npm run dev     # http://localhost:4000
```

Environment variables:

| Var                | Default     | Purpose                                   |
|--------------------|-------------|-------------------------------------------|
| `PORT`             | `4000`      | HTTP port                                 |
| `YTDLP_BIN`        | `yt-dlp`    | Path/name of the yt-dlp binary            |
| `YTDLP_TIMEOUT_MS` | `30000`     | How long to wait for yt-dlp before killing|
| `YTDLP_DISABLED`   | (unset)     | Set to `true` to disable the fallback     |
| `DEBUG`            | (unset)     | Set to `true` for verbose logs            |

## API

### `GET /health`

```json
{ "success": true, "status": "ok", "uptime": 12.34 }
```

### `POST /resolve`

Request:

```json
{ "url": "https://www.youtube.com/watch?v=xxxx" }
```

Success response:

```json
{
  "success": true,
  "title": "The Architect's Dream Sequence",
  "downloadUrl": "https://rrN---sn-xxx.googlevideo.com/videoplayback?…",
  "type": "direct",
  "contentType": "video/mp4",
  "contentLength": 48293011,
  "httpHeaders": {
    "User-Agent": "Mozilla/5.0 …"
  },
  "source": "yt-dlp"
}
```

- `source` — `"direct"` (HEAD probe) or `"yt-dlp"` (extractor fallback).
- `httpHeaders` — additional headers the Flutter client must send on the
  download request. For plain direct URLs this is an empty object.

### Error response shape

```json
{
  "success": false,
  "code": "UNSUPPORTED_MEDIA",
  "message": "…"
}
```

| Code                | HTTP | Meaning                                                |
|---------------------|------|--------------------------------------------------------|
| `INVALID_URL`       | 400  | Missing, malformed, wrong scheme, private host         |
| `UNSUPPORTED_MEDIA` | 415  | Neither direct probe nor yt-dlp could extract media    |
| `TIMEOUT`           | 504  | Upstream or yt-dlp exceeded its timeout                |
| `HOST_UNREACHABLE`  | 502  | DNS failure                                            |
| `UPSTREAM_ERROR`    | 502  | Upstream returned a non-2xx status                     |
| `NETWORK_FAILURE`   | 502  | Generic network failure                                |
| `YTDLP_MISSING`     | 500  | yt-dlp binary not installed / not in PATH              |
| `INTERNAL_ERROR`    | 500  | Unexpected server error                                |

## Legal / TOS note

yt-dlp extracts media URLs by parsing the target site's HTML and JS. This
may conflict with the **Terms of Service of YouTube, Facebook, Instagram,
TikTok, etc.** — which typically prohibit automated downloading of
user-uploaded content. Copyright on the downloaded content belongs to the
original uploader.

Use this service for:
- Your own uploaded content
- Content with an explicit download license (CC-BY, public domain, …)
- Fair-use scenarios permitted by your jurisdiction
- Educational / research projects against test fixtures

The author of this project makes no warranty about TOS compliance or
content rights. Ship this to real users at your own risk.

## How the flow works

```
POST /resolve { url }
        │
        ▼
  validateUrl (reject non-http, malformed, private hosts)
        │
        ▼
  resolveDirect()   ── HEAD (→ ranged GET fallback)
        │
        ├─ video/* or .mp4/.m3u8/…  →  return { source: "direct" }
        │
        └─ HTML or other / probe fails
              │
              ▼
        resolveWithYtDlp()  (child_process.spawn yt-dlp --dump-single-json)
              │
              ├─ pick best progressive MP4 (or manifest) → return { source: "yt-dlp" }
              └─ yt-dlp failed / nothing usable → 415 UNSUPPORTED_MEDIA
```
