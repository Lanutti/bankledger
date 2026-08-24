COBOL = cobc
SOURCE = src/programs/BANKLEDGER.CBL
BUILD_DIR = build
BINARY = $(BUILD_DIR)/bankledger

.PHONY: build run test clean

build:
	mkdir -p $(BUILD_DIR)
	$(COBOL) -x -o $(BINARY) $(SOURCE)

run: build
	./$(BINARY)

test:
	@echo "Test suite not implemented yet."

clean:
	rm -rf $(BUILD_DIR)