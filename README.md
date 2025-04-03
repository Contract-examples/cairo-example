# Cairo Starknet ERC20 Token Example

This is an ERC20 token implementation using the Cairo language and Starknet smart contract platform.

## Project Structure

- `src/token.cairo`: ERC20 token contract implementation
- `src/tests.cairo`: Unit tests
- `src/lib.cairo`: Module exports
- `Scarb.toml`: Project configuration file

## Features

This ERC20 token implementation includes the following features:

- Standard ERC20 interface: `transfer`, `approve`, `transferFrom`, `balanceOf`, `allowance`
- Extended functions: `increaseAllowance`, `decreaseAllowance`
- Events: `Transfer`, `Approval`

## Development Environment Setup

### Prerequisites

- [Scarb](https://docs.swmansion.com/scarb/download.html)
- [Starknet CLI](https://docs.starknet.io/documentation/getting_started/installation/)
- MacOS: ``brew install scarb``

### Installation

1. Clone the repository:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.starkup.sh | sh
```

### Build

```bash
scarb build
```

## Testing

Run unit tests:

```bash
scarb test
```

## Deploying to Starknet

### 1. Start a local development network (optional)

```bash
starknet-devnet --seed 0
```

### 2. Set up your account

If using a local development network, you can fetch a predeployed account:
```bash
starkli account fetch 0x064b48806902a367c8598f4f95c305e8c1a1acba5f082d294a43793113115691 --output account.json --rpc http://127.0.0.1:5050
starkli signer keystore from-key keystore.json  # Enter private key: 0x0000000000000000000000000000000071d7bb07b9a64f6f78ac4c816aff4da9
```

Set environment variables:
```bash
export STARKNET_ACCOUNT=$(pwd)/account.json
export STARKNET_KEYSTORE=$(pwd)/keystore.json
```

### 3. Declare the contract

```bash
starkli declare target/dev/token_ERC20Token.contract_class.json --rpc http://127.0.0.1:5050
```

If using mainnet or testnet:
```bash
starkli declare target/dev/token_ERC20Token.contract_class.json --network sepolia
```

### 4. Deploy the contract

Use the returned Class Hash to deploy the contract:
```bash
starkli deploy <class_hash> <name> <symbol> <decimals> <initial_supply> <recipient> --rpc http://127.0.0.1:5050
```

For example:
```bash
starkli deploy 0x0785c92bf4aa7a89fb62371802aef2f58e2333d8df7e2aadf938efa83735431c 'MyToken' 'MTK' 18 1000 0x064b48806902a367c8598f4f95c305e8c1a1acba5f082d294a43793113115691 --rpc http://127.0.0.1:5050
```

## Interacting with the Contract

### Read Functions

```bash
# Query token name
starkli call <contract_address> name --rpc http://127.0.0.1:5050

# Query total supply
starkli call <contract_address> total_supply --rpc http://127.0.0.1:5050

# Query balance
starkli call <contract_address> balance_of <address> --rpc http://127.0.0.1:5050

# Query allowance
starkli call <contract_address> allowance <owner> <spender> --rpc http://127.0.0.1:5050
```

### Write Functions

```bash
# Transfer tokens
starkli invoke <contract_address> transfer <recipient> <amount> --rpc http://127.0.0.1:5050

# Approve spending
starkli invoke <contract_address> approve <spender> <amount> --rpc http://127.0.0.1:5050

# Transfer from
starkli invoke <contract_address> transfer_from <sender> <recipient> <amount> --rpc http://127.0.0.1:5050
```

