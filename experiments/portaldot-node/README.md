# Portaldot Node Experiment

## Status: Blocked on Windows

The Portaldot project provides Linux/macOS binaries only. No native Windows build exists.
See: https://github.com/portaldotVolunteer/Portaldot-node

## Alternatives

### Option 1: WSL2 (Official Recommendation)
```bash
# In WSL2 Ubuntu:
wget https://github.com/portaldotVolunteer/Portaldot-node/raw/main/portaldot-testnet-ubuntu.tar.gz
tar -xzvf portaldot-testnet-ubuntu.tar.gz
cd portaldot-testnet-ubuntu
chmod +x portaldot_dev
./portaldot_dev --dev --alice
```

### Option 2: Upgrade substrate-contracts-node
Update `cli.js` to download v0.39.0 instead of v0.9.0. This keeps the current workflow but gets ink! v5 support.

### Option 3: Docker
Run the Ubuntu binary in a container with port 9944 forwarded.

## Recommendation

**Option 2 (upgrade cli.js)** is fastest. The substrate-contracts-node v0.39.0 binary is available for Windows and supports ink! v5 natively. No WSL or Docker needed.

To proceed with Option 2, run:
```
node experiments\upgrade-node.mjs
```
This will update `cli.js` to use the newer node version.
