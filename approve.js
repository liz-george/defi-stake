const abi = require('./abi');
const Web3 = require('web3');
let Tx = require("ethereumjs-tx").Transaction;
const Common = require("ethereumjs-common").default;

const web3 = new Web3(new Web3.providers.HttpProvider('https://rpc-mumbai.maticvigil.com/v1/{token}'));

const contractAddress = '0xCD0B996e579248Ec8a67e7B3964AdE87A4b26FaE'
const amount = '1000000000000000000';
const toAddress = '0xE4cbD75867a5F9215e44dFf980187aac19DAfb03';
const tokenAddress = '0xbbb72255e1AE16EE398D57c62Bfc131749D68793' // Stake
const fromAddressPrivateKey = 'privatekey';
let network = 'polygon-mumbai'
async function run () {

    const tokenContract = new web3.eth.Contract(abi, tokenAddress);
    let tokenInputData = await tokenContract.methods.approve(contractAddress, amount).encodeABI();
    const gasPrice = 2 * 1e9,
    gasLimit = await web3.utils.toHex(300000);
    const nonce = await web3.eth.getTransactionCount(toAddress);


    var rawTransaction = {
        to: tokenAddress,
        from: toAddress,
        nonce: await web3.utils.toHex(nonce),
        gasPrice: await web3.utils.toHex(gasPrice),
        gasLimit: await web3.utils.toHex(gasLimit),
        data: tokenInputData,
        value: await web3.utils.toHex(0),
        chainID: await web3.utils.toHex(80001)
    };
    console.log(rawTransaction);
    const privateKey = fromAddressPrivateKey;
    var privKey = Buffer.from(privateKey, 'hex');
    const txOptions = await getTransactionOptions();
   
    const tx = new Tx(rawTransaction, txOptions);

    tx.sign(privKey);
    var serializedTx = tx.serialize();
    web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'), async function (err, hash) {
        if (!err) {
            console.log('Txn Sent and hash is ' + hash);
        } else {
            console.log(err);
        }
})
}

async function getTransactionOptions ()  {
    switch (network) {
      case "mainnet":
      case "ropsten":
      case "rinkeby":
      case "kovan":
      case "goerli":
      case "calaveras":
        return { chain: network };
  
      case "polygon-mainnet":
        return {
          common: Common.forCustomChain(
            "mainnet",
            {
              name: network,
              chainId: 137,
              networkId: 137
            },
            'byzantium'
          )
        };
  
      case "polygon-mumbai": {
        return {
            common: Common.forCustomChain(
              "goerli",
              {
                name: network,
                chainId: 80001,
                networkId: 80001
              },
              'byzantium'
            )
          };
          
      }
        
  
      case "xDai":
        return {
          common: Common.forCustomChain(
            "mainnet",
            {
              name: network,
              chainId: 100,
              networkId: 100
            },
            'byzantium'
          )
        };
  
      default:
        throw Error("Unsupported chain");
    }
  }

run();
