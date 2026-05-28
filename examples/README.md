# Examples

Sample ink! contracts for Portaldot.

## Token (ERC-20)

A simple fungible token with transfers and allowances.

### Build

```bash
cd examples/token
cargo contract build
```

This produces `target/ink/token.contract`.

### Deploy

1.  Open the DevSuite Dashboard.
2.  Go to the **Contracts** tab.
3.  Upload `target/ink/token.contract`.
4.  Fill constructor args (e.g., `1000000` for initial supply).
5.  Click **Deploy**.

### Interact

Once deployed, use the **Interact** panel to call `transfer`, `balance_of`, etc.
