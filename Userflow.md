# User Flow Matrix: Happy Path Design

This matrix tracks the end-to-end user experience for a developer utilizing the DevSuite to build, deploy, and verify smart contracts locally without a public network connection.

## Phase 1: Environment Ingestion
*   **User Interaction:** The developer downloads the DevSuite directory directly into their local workspace (Windows, macOS, or Linux) and reviews the repository structure.
*   **System Action:** The system presents a clean file structure with clear separation between binary runtimes (organized by platform), static interface assets, and code templates.

## Phase 2: One-Click Initialization
*   **User Interaction:** The developer invokes the primary lifecycle command via `./devsuite.sh up` (POSIX) or `.\devsuite.ps1 up` (PowerShell).
*   **System Action:** 
    *   The execution script sweeps local environment dependencies to ensure runtime prerequisites are satisfied.
    *   The script detects the host OS and selects the matching pre-compiled node binary from `bin/`.
    *   The core node is spun up as a detached background daemon, allocating local communication ports and enabling instant block finalization.
    *   The local file server mounts the visualization assets and opens an edge server gateway.
    *   The terminal outputs a clean confirmation message displaying the local network topography and access points.

## Phase 3: Visual Workspace Validation
*   **User Interaction:** The developer targets their standard web browser to the local loopback interface address on port 3000.
*   **System Action:** The system loads the interface entirely from local files. It auto-detects the WebSocket connection running on port 9944, exposes pre-funded genesis development identities (Alice, Bob) carrying full token balances, and sets the block tracking height to an idle zero-state.

## Phase 4: Development & Instant Verification
*   **User Interaction:** The developer copies a pre-configured smart contract template, compiles it locally into a WebAssembly artifact, and uploads the file directly through the local user interface.
*   **System Action:** The contract instantiation transaction is signed and broadcast. The instant-sealing engine immediately processes the transaction, commits the state changes to Block #1 within milliseconds, and updates the local interface view to reflect successful deployment without idle confirmation delay.