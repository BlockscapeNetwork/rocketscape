# lint
lint-vault16:
	@echo "linting vault16 contract..."
	@npx solhint src/BlockscapeValidatorNFT.sol
.PHONY: lint-vault16

# docs
gen-docs:
	@echo "generating docs..."
	@echo forge doc
.PHONY: gen-docs

build-docs:
	@echo "building docs..."
	@echo forge doc --build
.PHONY: build-docs

serve-docs:
	@echo "serving docs..."
	@forge doc --serve --port 4000
.PHONY: serve-docs

# testing
test-watch-verbose-optimize:
	@echo "forge testing"
	@forge test -vvvvv --fork-url ${MAINNET_RPC_URL} --optimize --watch
.PHONY: test-watch-verbose

# use like `make test-watch-verbose verbose=-vv`
# we're testing just before the block where not enough stake was available
# 16376810 - 1, see the following tx which staked RPL
# https://etherscan.io/tx/0x944093ca45dd60ea392a7a28afa14c76f0341535f66184f178dbafb19bac6fc3
test-watch-verbose:
	@echo "forge testing"
	@forge test \
		--watch \ 
		$(verbose) \
		--fork-url ${MAINNET_RPC_URL} \
		--fork-block-number 16376809
.PHONY: test-watch-verbose

test-verbose:
	@echo "forge testing"
	@forge test \
		$(verbose) \
		--fork-url ${MAINNET_RPC_URL} \
		--fork-block-number 16376809
.PHONY: test-verbose

