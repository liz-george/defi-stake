const pinataSDK = require('@pinata/sdk');
const pinata = pinataSDK('6ba4a5f3223006f969fa', 'd869caa5bb722cdf09ca14385118db04f6e4550f429b8f2e936a1a000db089ee');

const JSONBody = {
    userAddress : "0xf44c3adacC1aeb083625bA0B6d0a953DFce86F94", 
    stakeAmount : "1 QUEST",
    reward : "1.41151395 FIN",
    stakeTokenAddress : "0x83B00Bf9c3bea20b70d4261400664C7be10E71D9"
}
async function pinJSONToIPFS(JSONBody) {
    let json = await pinata.pinJSONToIPFS(JSONBody);
    console.log(json, 'JSON');
    return json;  
}

pinJSONToIPFS(JSONBody)
