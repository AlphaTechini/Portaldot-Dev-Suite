# Contributing to Portaldot

Thank you for your interest in contributing to Portaldot. We welcome contributions that improve the developer experience for the Substrate ecosystem.

## Development Philosophy

Portaldot is built with a specific focus on efficiency and architectural integrity. To maintain this standard, we adhere to the following guidelines:

### 1. Human-Led Architecture
While we embrace the use of AI tools to accelerate code generation and boilerplate reduction, **all architectural decisions must be planned and reviewed by human developers.** AI is a tool for implementation, not a substitute for system design.

### 2. Manual Review is Mandatory
If you use AI to generate code, **you must manually review every change before contributing.** Do not submit AI-generated code blindly. Ensure that:
*   The code follows the project's established patterns.
*   There are no hidden security vulnerabilities or inefficiencies.
*   The logic aligns with the intended feature behavior.

## How to Contribute

1.  **Fork the Repository:** Create your own fork of the project.
2.  **Create a Branch:** Work on a dedicated branch for your feature or fix.
3.  **Implement & Review:** Write your code, apply the review guidelines above, and test thoroughly.
4.  **Submit a Pull Request:** Open a PR with a clear description of the changes and the problem they solve.

## Code Standards

*   **TypeScript/JavaScript:** Use modern ES modules. Avoid legacy CommonJS patterns unless required by a specific dependency.
*   **Rust (Contracts):** Follow `ink! 4.3.0` conventions. Ensure all contracts compile with `cargo-contract v3.2.0`.
*   **Commit Messages:** Use conventional commits (e.g., `feat: add new feature`, `fix: resolve bug`).

## Reporting Issues

If you find a bug or have a feature request, please open an issue in the repository. Include as much detail as possible, including steps to reproduce and your environment setup.

---

By contributing to Portaldot, you agree to uphold these standards and help us build a robust, reliable tool for the community.
