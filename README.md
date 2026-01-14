# TeraBox API on Cloudflare Workers

A high-performance, serverless API to resolve TeraBox share URLs, extract file metadata, and provide direct streaming/download links. Deployed on Cloudflare Workers.

## Features

- **Resolve System**: Handles redirects and extracts auth tokens (jsToken, logid, bdstoken).
- **Streaming**: Generates HLS (m3u8) playlists by "transferring" files to a temporary session.
- **Download Proxy**: Proxies downloads with strict header emulation to bypass 403 Forbidden.
- **Smart Caching**: Uses Cloudflare KV (optional but recommended) to cache resolved links and playlists.

## Prerequisites

- [Node.js](https://nodejs.org/) installed.
- [Cloudflare Account](https://dash.cloudflare.com/) (Free tier works).
- `wrangler` CLI installed (`npm install -g wrangler`).

## Deployment

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Login to Cloudflare**
   ```bash
   npx wrangler login
   ```

3. **Create KV Namespace (Critical for Streaming)**
   Because Workers are stateless, we use KV to store the file metadata and session cookies required for streaming/downloading after the initial resolve.
   ```bash
   npx wrangler kv:namespace create TERA_CACHE
   ```
   *Copy the `id` from the output.*

4. **Update Configuration**
   Open `wrangler.toml` and replace the `id` under `[[kv_namespaces]]` with your new ID.

   ```toml
   [[kv_namespaces]]
   binding = "TERA_CACHE"
   id = "YOUR_KV_ID_HERE"
   ```

5. **Deploy**
   ```bash
   npx wrangler deploy
   ```

## Usage

### 1. Resolve a TeraBox URL
**POST** `/resolve`
```json
{
  "url": "https://1024terabox.com/s/1xH..."
}
```

**Response:**
```json
{
  "ok": true,
  "id": "123456789",
  "metadata": {
    "filename": "video.mp4",
    "size": 1024000,
    "dlink": "https://d.terabox.com/..."
  },
  "links": {
    "stream": "/stream/123456789.m3u8",
    "download": "/download/123456789"
  }
}
```

### 2. Stream (HLS)
Use the `stream` link in any HLS video player (e.g., VLC, HLS.js).
`https://your-worker.workers.dev/stream/123456789.m3u8`

### 3. Download
`https://your-worker.workers.dev/download/123456789`
(This will force a file download with the correct filename).

## Local Development
To test locally:
```bash
npx wrangler dev
```
Then use `http://localhost:8787` for your requests.
