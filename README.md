### Install
```sh
yarn
```


### Conf
Copy hardhat config.
```sh
cp hardhat.data.example.json .hardhat.data.json
```
Fill with your own conf.
```json
{
  "PrivateKey": "", // Creater a account by Chrome Metamask wallet.
  "InfuraApiKey": "", // If you don't have one, please register in https://infura.io/dashboard.
  "EtherscanApiKey": "", // If you don't have one, please register in https://etherscan.io/login.
  "BscscanApiKey": "" // If you don't have one, please register in https://bscscan.com/login.
}
```
If there is a new account, you need get some gas token from facut.

[Ethereum Rinkeby Faucet](https://rinkebyfaucet.com/)

[BSC Test Faucet](https://testnet.binance.org/faucet-smart)


### Cmd
```sh
# compile
yarn compile

# test
yarn test test/Example.spec.ts

# deploy
yarn deploy:bsctestnet

# deploy with proxy
yarn proxy:bsctestnet
```