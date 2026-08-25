COBOL = cobc
SOURCE = src/programs/BANKLEDGER.CBL
BUILD_DIR = build
BINARY = $(BUILD_DIR)/bankledger.exe
COPYBOOK_DIR = src/copybooks

.PHONY: build run test clean

build:
	mkdir -p $(BUILD_DIR)
	$(COBOL) -I $(COPYBOOK_DIR) -x -o $(BINARY) $(SOURCE)

run: build
	./$(BINARY)

test:
	@echo "Test suite not implemented yet."

clean:
	rm -rf $(BUILD_DIR)