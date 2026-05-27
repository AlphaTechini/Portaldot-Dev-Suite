const http = require("http");
const fs = require("fs");
const path = require("path");

const dashboardDir = process.argv[2] || path.join(__dirname, "..", "dashboard");
const port = parseInt(process.argv[3], 10) || 3000;

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

const server = http.createServer((req, res) => {
    let filePath = path.join(dashboardDir, req.url === "/" ? "index.html" : req.url);
    const ext = path.extname(filePath).toLowerCase();
    const contentType = mimeTypes[ext] || "application/octet-stream";

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
        res.writeHead(200, {
            "Content-Type": contentType,
            "Cache-Control": "no-cache",
        });
        res.end(data);
    });
});

server.listen(port, "127.0.0.1", () => {
    console.log(`Dashboard server running on http://127.0.0.1:${port}`);
});

process.on("SIGTERM", () => server.close());
process.on("SIGINT", () => server.close());
