# Bitcoin Wallet CLI

A command-line interface for managing Bitcoin testnet transactions.

## Setup

### Prerequisites
- Docker
- Docker Compose

### Installation

1. Build the Docker image:
   ```
   make build_image
   ```
2. Install dependencies:
    ```
    make install_gems
   ```
## Usage
### Generate New Key
1. Generate a new Bitcoin testnet address and private key:
    ```
    make generate
    ```
    The private key will be saved in the `/key/<wallet_address>.key` file.


2. Check Balance
    ```
    make balance from=<wallet_address>
    ```

3. Send Bitcoin
     ```
    make send amount=<amount_in_btc> from=<wallet_address> to=<recipient_address>
     ```
    Example:
     ```
    make send amount=0.001 from=mzR8ELqX7nEJATBYAstNneJiR2uXyozkB6 to=n1ranndRzrPQmswW2uktbrBEoWDmhSov7S
     ```
   
## Debugging (development)

1. To access the container's shell:
    ```
    make bash
    ```
2. Run Tests
    ```
    make rspec
    ```

3. Run Rubocop linter:
    ```
    make rubocop
    ```
4. Fix auto-correctable Rubocop issues:
    ```
    make rubocop_ac
    ```

## Notes
#### This wallet works only with Bitcoin testnet.
#### Private keys are stored locally in the key/ directory.
#### All amounts are in BTC (not satoshis).
