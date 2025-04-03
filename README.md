

# Cairo Starknet ERC20 Token Example

This is an example of an ERC20 token implemented using the Cairo language and the Starknet smart contract platform.

## Project Structure

- `src/token.cairo`: ERC20 token contract implementation
- `src/tests.cairo`: Unit tests
- `src/lib.cairo`: Exported module
- `Scarb.toml`: Project configuration file

## Features

This ERC20 token implementation includes the following features:

- Standard ERC20 interface: `transfer`, `approve`, `transferFrom`, `balanceOf`, `allowance`
- Extended functions: `increaseAllowance`, `decreaseAllowance`
- Events: `Transfer`, `Approval`

## Development Environment Setup

### Prerequisites
- [Scarb && Starknet](https://docs.starknet.io/quick-start/environment-setup/)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Contract-examples/cairo-example
```

2. Build using Scarb:
```bash
scarb build
```

## Testing

Run unit tests:

```bash
scarb test
```

## Deploy to Starknet

1. Build the contract:
```bash
scarb build
```

2. Declare the contract class:
```bash
starknet declare --contract target/dev/token_ERC20Token.sierra.json
```

3. Deploy the contract:
```bash
starknet deploy --class_hash <class-hash> --inputs <name> <symbol> <decimals> <initial_supply> <recipient_address>
```

For example:
```bash
starknet deploy --class_hash 0x123abc... --inputs 0x4d79546f6b656e 0x4d544b 18 1000 0x456def...
```

## Interacting with the Contract

After deployment, you can interact with the contract using the Starknet CLI:

```bash
# Query token name
starknet call --contract_address <contract_address> --function name

# Query balance
starknet call --contract_address <contract_address> --function balance_of --inputs <address>

# Transfer tokens
starknet invoke --contract_address <contract_address> --function transfer --inputs <recipient_address> <amount>
```
