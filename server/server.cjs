const http = require("http");
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");
const os = require("os");

const dashboardDir = process.argv[2] || path.join(__dirname, "..", "dashboard");
const port = parseInt(process.argv[3], 10) || 3000;
const nodePort = parseInt(process.argv[4], 10) || 9944;

function detectWsUrl() {
    try {
        const raw = execSync("wsl -e bash -c \"ip -4 addr show eth0 2>/dev/null\"", {
            encoding: "utf8",
            timeout: 15000,
            windowsHide: true,
        });
        const match = raw.match(/inet\s+(\d+\.\d+\.\d+\.\d+)/);
        if (match && match[1]) return `ws://${match[1]}:${nodePort}`;
    } catch {
        // Not on WSL or timed out
    }
    return `ws://localhost:${nodePort}`;
}

const WS_URL = detectWsUrl();

const mimeTypes = {
    ".html": "text/html; charset=utf-8",
    ".js": "application/javascript; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".png": "image/png",
    ".svg": "image/svg+xml",
    ".ico": "image/x-icon",
    ".wasm": "application/wasm",
    ".woff": "font/woff",
    ".woff2": "font/woff2",
    ".ttf": "font/ttf",
};

function serveFile(filePath, res, inject) {
    fs.readFile(filePath, (err, data) => {
        if (err) {
            if (err.code === "ENOENT") {
                res.writeHead(404, { "Content-Type": "text/plain" });
                res.end("Not Found");
            } else {
                res.writeHead(500, { "Content-Type": "text/plain" });
                res.end("Internal Server Error");
            }
            return;
        }

        let body = data;
        if (inject) {
            body = Buffer.from(data.toString().replace("__WS_URL__", WS_URL));
        }

        const ext = path.extname(filePath).toLowerCase();
        res.writeHead(200, {
            "Content-Type": mimeTypes[ext] || "application/octet-stream",
            "Cache-Control": "no-cache",
        });
        res.end(body);
    });
}

const server = http.createServer((req, res) => {
    let filePath = path.join(dashboardDir, req.url === "/" ? "index.html" : req.url);
    const inject = filePath.endsWith("index.html") || filePath.endsWith("index.htm");
    serveFile(filePath, res, inject);
});

server.listen(port, "0.0.0.0", () => {
    const interfaces = os.networkInterfaces();
    let localIp = "localhost";
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === "IPv4" && !iface.internal && iface.address.startsWith("192.168.")) {
                localIp = iface.address;
                break;
            }
        }
        if (localIp !== "localhost") break;
    }

    console.log(`Dashboard server running on http://localhost:${port}`);
    console.log(`  Also accessible at: http://${localIp}:${port}`);
    console.log(`  WebSocket endpoint: ${WS_URL}`);
});

process.on("SIGTERM", () => server.close());
process.on("SIGINT", () => server.close());
