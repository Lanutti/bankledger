# BankLedger

**BankLedger** is a batch-oriented banking ledger system implemented in **COBOL**.

The project simulates the processing model used by traditional financial systems, focusing on sequential file processing, transaction validation, account management, rejection handling, and deterministic batch execution.

The project is intentionally being developed incrementally, with each feature introduced through isolated Git branches and focused commits.

---

## Overview

BankLedger processes financial transactions stored in sequential files.

The current processing flow is:

```text
Input Files
    |
    v
File Reader
    |
    v
Transaction Parsing
    |
    v
Validation
    |
    +--------------------+
    |                    |
    v                    v
Valid Transaction    Rejected Transaction
    |                    |
    v                    v
Account Processing   Rejection File
    |
    v
Processed Transactions
    |
    v
Updated Account Data
```

The system is designed to demonstrate how a traditional COBOL batch-processing application can be structured around sequential files, explicit validation rules, deterministic execution, and auditable processing results.

---

## Current Features

The current implementation includes:

- COBOL batch processing
- Sequential file processing
- Transaction parsing
- Transaction validation
- Account loading
- Account lookup
- Account existence validation
- Account status validation
- Deposit processing
- Withdrawal processing
- Insufficient-funds validation
- Rejected transaction handling
- Rejection reason generation
- Processed transaction recording
- Updated account data generation
- Transaction counters
- Valid/rejected transaction counters
- Makefile-based build and execution
- Automated test structure
- Incremental Git-based development

---

## Technology Stack

### Language

- COBOL
- GnuCOBOL

### Build

- GNU Make
- MSYS2 / UCRT64

### Version Control

- Git
- GitHub

### Testing

- Make-based test execution
- Deterministic input datasets
- Expected-output validation

---

## Project Structure

```text
bankledger/
|
+-- src/
|   |
|   +-- copybooks/
|   |   +-- ACCOUNT.CPY
|   |   +-- TRANSACT.CPY
|   |   +-- TRXVALID.CPY
|   |
|   +-- programs/
|       +-- BANKLEDGER.CBL
|
+-- data/
|   |
|   +-- input/
|   |   +-- accounts.dat
|   |   +-- transactions.dat
|   |
|   +-- output/
|       +-- rejected_transactions.dat
|       +-- processed_transactions.dat
|       +-- accounts_updated.dat
|
+-- tests/
|   |
|   +-- input/
|   |   +-- transactions_test.dat
|   |
|   +-- expected/
|       +-- rejected_transactions_expected.dat
|
+-- build/
|
+-- docs/
|
+-- scripts/
|
+-- .github/
|   +-- workflows/
|
+-- .gitignore
+-- LICENSE
+-- Makefile
+-- README.md
```

---

# Input Data

BankLedger currently works with two primary input files.

## Accounts

`data/input/accounts.dat`

Example:

```text
000001|10001|CHECKING|00000150000|ACTIVE
000002|10002|SAVINGS|00000350050|ACTIVE
000003|10003|CHECKING|00000085000|BLOCKED
000004|10004|SAVINGS|00001000000|ACTIVE
000005|10005|CHECKING|00000025000|ACTIVE
```

The account record contains:

```text
ACCOUNT_ID
CUSTOMER_ID
ACCOUNT_TYPE
ACCOUNT_BALANCE
ACCOUNT_STATUS
```

---

## Transactions

`data/input/transactions.dat`

Example:

```text
00000001|000001|DEPOSIT|00000010000
00000002|000001|WITHDRAWAL|00000005000
00000003|000002|DEPOSIT|00000025000
00000004|000002|WITHDRAWAL|00000010000
00000005|000001|TRANSFER|00000005000
00000006|000003|WITHDRAWAL|00000090000
00000007|000999|DEPOSIT|00000010000
00000008|000001|DEPOSIT|00000000000
```

The transaction record contains:

```text
TRANSACTION_ID
ACCOUNT_ID
TRANSACTION_TYPE
TRANSACTION_AMOUNT
```

---

# Transaction Processing

Each transaction passes through a deterministic validation pipeline.

## Transaction ID

The transaction ID must contain numeric data and cannot be zero.

Invalid transactions generate:

```text
INVALID_TRANSACTION_ID
```

---

## Account ID

The account ID must contain numeric data and cannot be zero.

Invalid transactions generate:

```text
INVALID_ACCOUNT_ID
```

---

## Transaction Amount

The transaction amount must be numeric and greater than zero.

Invalid transactions generate:

```text
INVALID_AMOUNT
```

---

## Transaction Type

The currently recognized transaction types are:

```text
DEPOSIT
WITHDRAWAL
TRANSFER
```

Invalid types generate:

```text
INVALID_TRANSACTION_TYPE
```

---

# Account Validation

Transactions are associated with an account before financial processing occurs.

## Account Existence

The transaction account must exist in the loaded account dataset.

If the account cannot be found:

```text
ACCOUNT_NOT_FOUND
```

is generated.

---

## Account Status

Only active accounts can currently perform financial operations.

For example:

```text
000003|10003|CHECKING|00000085000|BLOCKED
```

cannot be used for normal transaction processing.

The corresponding rejection reason is:

```text
ACCOUNT_NOT_ACTIVE
```

---

# Financial Operations

## Deposit

A deposit increases the account balance by the transaction amount.

Conceptually:

```text
new_balance = current_balance + amount
```

---

## Withdrawal

A withdrawal decreases the account balance.

Before the withdrawal is applied, the system verifies that sufficient funds are available.

Conceptually:

```text
if balance >= amount:
    balance = balance - amount
```

Otherwise:

```text
INSUFFICIENT_FUNDS
```

is generated.

---

## Transfer

Transfer processing is currently represented as a controlled validation path.

The current transaction format contains only:

```text
TRANSACTION_ID
ACCOUNT_ID
TRANSACTION_TYPE
TRANSACTION_AMOUNT
```

A complete transfer requires both a source and destination account.

Therefore, transfer execution is intentionally prevented until the transaction model is extended to represent the destination account explicitly.

The current system generates:

```text
TRANSFER_DESTINATION_REQUIRED
```

for unsupported transfer execution.

This keeps the financial model explicit instead of inferring or inventing a destination account.

---

# Rejected Transactions

Invalid transactions are written to:

```text
data/output/rejected_transactions.dat
```

The rejection record contains:

```text
TRANSACTION_ID
ACCOUNT_ID
ERROR_CODE
AMOUNT
```

Example:

```text
00000007|000999|ACCOUNT_NOT_FOUND|00000010000
```

This allows rejected transactions to be analyzed separately from successfully processed operations.

---

# Processing Results

The application displays batch-processing statistics after execution.

Example:

```text
========================================
             BANKLEDGER
========================================
----------------------------------------
TOTAL TRANSACTIONS:    00009
VALID TRANSACTIONS:    00000
REJECTED TRANSACTIONS: 00009
----------------------------------------
```

These counters provide a simple processing summary for the batch execution.

---

# Build

The project uses a `Makefile` to standardize the development workflow.

## Build

```bash
make build
```

This compiles:

```text
src/programs/BANKLEDGER.CBL
```

and generates the executable under:

```text
build/
```

---

## Run

```bash
make run
```

The command builds the application and executes the resulting program.

---

## Clean

```bash
make clean
```

Removes generated build artifacts.

---

## Test

```bash
make test
```

Runs the project's test workflow using controlled transaction input data.

---

# Development Environment

The project was developed and tested using:

```text
Windows
MSYS2
UCRT64
GnuCOBOL
GNU Make
Git
```

GnuCOBOL is used to compile the COBOL source code into a Windows executable.

---

# Development Approach

BankLedger is intentionally developed incrementally.

Each meaningful feature is introduced through focused Git commits and, when appropriate, isolated branches.

The development history is therefore part of the project itself.

Example branch naming convention:

```text
feat/transaction-processing
feat/account-processing
fix/transaction-validation
test/transaction-processing
```

Commit messages follow a conventional structure such as:

```text
feat: implement account lookup
fix: handle rejected transactions
test: add transaction processing test suite
build: configure cobol build environment
docs: update project documentation
```

This approach makes the repository history easier to understand and demonstrates a professional development workflow.

---

# Roadmap

The following features are planned for future iterations:

- [ ] Complete source/destination transfer model
- [ ] Atomic transfer processing
- [ ] Persistent account updates
- [ ] Extended financial validation
- [ ] Improved error handling
- [ ] Comprehensive automated tests
- [ ] Regression test suite
- [ ] Financial reporting
- [ ] Batch processing metrics
- [ ] Audit ledger
- [ ] Performance benchmarks
- [ ] CI pipeline
- [ ] Code quality checks
- [ ] Release preparation
- [ ] `v1.0.0`

---

# Project Status

🚧 **Active development**

The current version implements the core batch-processing foundation, transaction validation, account validation, deposits, withdrawals, rejection handling, and structured processing outputs.

Transfer processing and some production-level features remain under development.

---

# License

This project is licensed under the **MIT License**.
