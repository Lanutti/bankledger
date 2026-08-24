# BankLedger

**BankLedger** is a batch-oriented banking ledger system implemented in **COBOL**.

The project simulates the core operations of a traditional financial batch-processing system, with a focus on:

- Reliability
- Deterministic processing
- Transaction validation
- Auditability
- Structured financial reporting
- Automated testing
- Performance analysis

The architecture is intentionally based on **batch processing**, reflecting characteristics commonly found in legacy financial systems.

## Goals

- Demonstrate COBOL programming
- Implement structured financial transaction processing
- Process sequential files
- Build a batch-oriented architecture
- Manage customer accounts
- Support deposits, withdrawals, and transfers
- Validate financial transactions
- Handle rejected transactions
- Maintain an audit ledger
- Generate financial reports
- Implement automated testing
- Perform performance analysis
- Integrate continuous integration

## Architecture

The planned processing pipeline is:

```text
Input Files
    |
    v
File Reader
    |
    v
Validation
    |
    v
Transaction Processor
    |
    +----------------+
    |                |
    v                v
Account Update    Rejection
    |                |
    v                v
Audit Ledger    Rejected Transactions
    |
    v
Reports
```

## Project Structure

```text
bankledger/
|
+-- src/
|   +-- copybooks/
|   +-- modules/
|   +-- programs/
|
+-- data/
|   +-- input/
|   +-- output/
|
+-- tests/
|
+-- docs/
|
+-- scripts/
|
+-- .github/
|   +-- workflows/
|
+-- README.md
+-- LICENSE
+-- Makefile
+-- .gitignore
```

## Data Processing

BankLedger uses structured input files to represent:

- Accounts
- Customers
- Financial transactions

Each record passes through validation before any financial operation is applied.

Invalid transactions are rejected and recorded separately, allowing valid transactions to continue processing.

## Financial Operations

### Deposit

Adds funds to an active account.

### Withdrawal

Removes funds from an active account while preventing insufficient-funds transactions.

### Transfer

Moves funds between two valid accounts.

Transfers must maintain financial consistency between the source and destination accounts.

## Validation

The system validates:

- Account existence
- Account status
- Transaction type
- Transaction amount
- Required fields
- Financial constraints
- Input record integrity

Invalid operations generate explicit rejection reasons.

## Auditability

Every processed transaction generates an audit record containing relevant information about:

- Operation
- Account
- Amount
- Processing status
- Transaction identification

Rejected operations are also recorded for auditing purposes.

## Reporting

The system will generate processing reports containing:

- Total transactions
- Successful transactions
- Rejected transactions
- Deposits
- Withdrawals
- Transfers
- Financial totals
- Rejection reasons
- Processing metrics

## Development Approach

BankLedger is being developed incrementally.

Each feature is implemented in an isolated **Git branch** and integrated into the `main` branch through small, focused commits.

This approach keeps the project history explicit and makes each development step independently understandable.

## Roadmap

- [ ] Project foundation
- [ ] Account processing
- [ ] Transaction processing
- [ ] Validation and rejection handling
- [ ] Batch processing
- [ ] Audit ledger
- [ ] Report generation
- [ ] Automated testing
- [ ] Performance testing
- [ ] Documentation
- [ ] CI pipeline
- [ ] `v1.0.0` release

## Status

🚧 **Under active development**

## License

This project is licensed under the **MIT License**.
