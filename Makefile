COBOL = cobc

SOURCE = src/programs/BANKLEDGER.CBL

BUILD_DIR = build

BINARY = $(BUILD_DIR)/bankledger

COPYBOOK_DIR = src/copybooks

.PHONY: build run test clean

build:
	mkdir -p $(BUILD_DIR)
	$(COBOL) -I $(COPYBOOK_DIR) -x -o $(BINARY) $(SOURCE)

run: build
	./$(BINARY).exe

test: build
	@echo "Running BankLedger transaction tests..."
	@mkdir -p build/test-data
	@cp tests/input/transactions_test.dat data/input/transactions.dat
	@./build/bankledger.exe
	@echo "Transaction tests completed."

clean:
	rm -rf $(BUILD_DIR)