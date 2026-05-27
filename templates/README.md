# templates/

Pre-configured ink! smart contract scaffolds with strict version pinning.

## Templates

### fungible-token/

Standard ERC-20-style fungible token contract.

To find the token logic visit [src/lib.rs](file:///C:/Hackathons/Portaldot/templates/fungible-token/src/lib.rs)

Features:
- `total_supply()` — Query total token supply
- `balance_of(owner)` — Query account balance
- `transfer(to, value)` — Transfer tokens
- `approve(spender, value)` — Approve spending allowance
- `transfer_from(from, to, value)` — Transfer on behalf of another account

Pinned dependencies:
- `ink = 4.3.0`
- `parity-scale-codec = 3.6.1`
- `scale-info = 2.6.0`

### escrow/

Multi-party escrow contract with arbiter dispute resolution.

To find the escrow logic visit [src/lib.rs](file:///C:/Hackathons/Portaldot/templates/escrow/src/lib.rs)

Features:
- `deposit()` — Fund the escrow (payable)
- `approve()` — Buyer releases funds to seller
- `refund()` — Arbiter refunds buyer
- `dispute()` — Either party raises a dispute
- `resolve_dispute(to_seller)` — Arbiter resolves dispute

Pinned dependencies:
- `ink = 4.3.0`
- `parity-scale-codec = 3.6.1`
- `scale-info = 2.6.0`

## Building

```bash
cargo +nightly contract build
```

Requires `cargo-contract` installed in your Rust toolchain.
