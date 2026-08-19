.PHONY: build test clean bigtest test-gas

build:
	cd code && forge build

test:
	cd code && forge test

clean:
	cd code && forge clean

bigtest:
	cd code && forge test -vvv

test-gas:
	cd code && forge test --gas-report