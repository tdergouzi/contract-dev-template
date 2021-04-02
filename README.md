## Smart Contract Doc

### Dev Record

#### compile
- single compile
- mul compile
- native solc compiler
  - reduce compile time
  - keep solidity version consistent

#### test
- single test
- mul test
- others test function

#### deploy
- single deploy
- mul deploy 
- generate .data.json as log

#### verify
- verify contract in etherscan according to .data.json.
- update .data.json to record verify status.

### Install
```sh
npm install hardhat
```

```sh
npm install typechain
```

### Cmd
compile
```sh
yarn compile
```
test
```sh
yarn test
```
deploy
```sh
npx hardhat run --network <your_network> scripts/deploy.ts
```
verify
```sh
npx hardhat verify --network <your_network> <contract_address> 
```