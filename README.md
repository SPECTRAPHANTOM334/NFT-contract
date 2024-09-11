<!-- @format -->

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

```

```

struct Feel {}
string private ear1 = "";
string private ear2 = "";
string[] private pn = []
string[] private feelsDownTraitNames = [];
string[] private feelsUpTraitNames = [];
string[] private props = [];
string[] private earrings = [];
string[] private hairsTypePropNames = [];
string[] private hairTypes = [];
string private mu = "";
string private m1 = "";
string private mn = "";
string private eyebrowLeft = "";
string private eyebrowRight = "";
string private p0 = "";
string private p1 = "";
string private p2 = "";
string private p3 = "";
string private p4 = "";
string private p5 = "";
string private p6 = "";
string private p7 = "";
string private p8 = "";
string private p9 = "";
string[] private eyeLeft = [];
string[] private eyeRight = [];
string[] private aparts = [];
string[] private facePropNames = [];
string[] private background = [];
string[] private eyesClr = [];
string[] private lipstickClr = [];
string[] private faceClr = [];
string[] private shirtClr = [];
string[] private hairClr = [];
function buildImage(uint256 \_tokenId) private view returns (string memory) {}
function toString(uint256 \_value) internal pure returns (string memory) {}
function randomOne(uint256 \_tokenId) internal pure returns (Feel memory) {}
function buildMetadata () private view returns (string memory) {}

forge script script/DeployMoodNft.s.sol:DeployMoodNft --rpc-url https://eth-sepolia.g.alchemy.com/v2/kKt_OAMq4af4UQNskZoRqFP_U17u5JL1 --private-key 74399ce7f70c3fde7e6f6885d37d6ef658d0942f9462ea082d087a395ccf9211 --broadcast --verify

forge script script/DeployMoodNft.s.sol:DeployMoodNft --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

verify

forge script script/DeployMoodNft.s.sol:DeployMoodNft --rpc-url https://eth-sepolia.g.alchemy.com/v2/kKt_OAMq4af4UQNskZoRqFP_U17u5JL1 --private-key 74399ce7f70c3fde7e6f6885d37d6ef658d0942f9462ea082d087a395ccf9211 --broadcast --etherscan-api-key KGK6TA1FVKU2MBH5FNMU17H36TXD3C9MAH --verify
