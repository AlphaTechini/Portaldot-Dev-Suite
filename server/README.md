# server/

Minimal Node.js static file server that serves the dashboard assets on port 3000.

## Files

- `server.js` — The server implementation. No dependencies beyond Node.js built-in modules (`http`, `fs`, `path`).

## Usage

```bash
node server/server.js <dashboard-dir> <port>
```

Called internally by `devsuite.sh` / `devsuite.ps1` during `up`.

## Design decisions

- No Express or other framework — keeps the dependency tree at zero
- No build step — runs directly with `node`
- Serves only on `127.0.0.1` — not accessible from the network
- Graceful shutdown on SIGTERM/SIGINT
