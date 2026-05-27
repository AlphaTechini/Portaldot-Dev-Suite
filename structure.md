# Portaldot DevSuite Project Structure

```
Portaldot/
  bin/
    linux-x64/       — Linux x86_64 substrate-contracts-node binary (gitignored, auto-downloaded)
    macos-arm64/     — macOS Apple Silicon node binary (gitignored, auto-downloaded)
    macos-x64/       — macOS Intel node binary (gitignored, auto-downloaded)
    windows-x64/     — Windows x64 node binary (gitignored, auto-downloaded)
    README.md        — Binary build process and launch flags
  config/
    portaldot-dev-spec.json — Custom chain spec (POT token, 14 decimals)
  dashboard/
    index.html       — Polkadot-JS Apps main entry point
    *.js, *.css      — Application bundles and styles
    assets/          — Images, fonts, icons
    README.md        — Dashboard integration instructions
  scripts/
    build-node.sh    — Cross-platform node binary builder (Docker)
    release.sh       — GitHub Release creator with binary uploads
    README.md        — Scripts documentation
  server/
    server.js        — Node.js static file server (zero dependencies)
    README.md        — Server design and usage
  templates/
    fungible-token/  — ink! fungible token contract scaffold
      src/lib.rs     — Token contract implementation
      Cargo.toml     — Pinned dependencies
    escrow/          — ink! escrow contract scaffold
      src/lib.rs     — Escrow contract implementation
      Cargo.toml     — Pinned dependencies
    README.md        — Template documentation and build instructions
  devsuite.sh        — POSIX shell controller (Linux/macOS)
  devsuite.ps1       — PowerShell controller (Windows)
  .gitignore         — Git ignore rules (binaries, state, env)
  Readme.md          — Project overview and quick start
  Requirements.md    — Engineering requirements and success metrics
  Userflow.md        — User journey documentation
  Implementation.md  — Build phase instructions
```

## Component Mapping

- **The CLI orchestration layer** can be found in [devsuite.sh](file:///C:/Hackathons/Portaldot/devsuite.sh) (POSIX) and [devsuite.ps1](file:///C:/Hackathons/Portaldot/devsuite.ps1) (PowerShell)
- **The static file server** can be found in [server/server.js](file:///C:/Hackathons/Portaldot/server/server.js)
- **The node binary directory** can be found in [bin/README.md](file:///C:/Hackathons/Portaldot/bin/README.md)
- **The build and release scripts** can be found in [scripts/README.md](file:///C:/Hackathons/Portaldot/scripts/README.md)
- **The custom chain spec** can be found in [config/portaldot-dev-spec.json](file:///C:/Hackathons/Portaldot/config/portaldot-dev-spec.json)
- **The dashboard UI** can be found in [dashboard/index.html](file:///C:/Hackathons/Portaldot/dashboard/index.html)
- **The fungible token contract** can be found in [templates/fungible-token/src/lib.rs](file:///C:/Hackathons/Portaldot/templates/fungible-token/src/lib.rs)
- **The escrow contract** can be found in [templates/escrow/src/lib.rs](file:///C:/Hackathons/Portaldot/templates/escrow/src/lib.rs)

## Folder READMEs

- [bin/](file:///C:/Hackathons/Portaldot/bin/README.md)
- [config/](file:///C:/Hackathons/Portaldot/config/README.md)
- [dashboard/](file:///C:/Hackathons/Portaldot/dashboard/README.md)
- [scripts/](file:///C:/Hackathons/Portaldot/scripts/README.md)
- [server/](file:///C:/Hackathons/Portaldot/server/README.md)
- [templates/](file:///C:/Hackathons/Portaldot/templates/README.md)
