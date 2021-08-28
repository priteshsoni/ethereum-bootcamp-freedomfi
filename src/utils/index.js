import { ethers } from 'ethers';
import { requestAccount, getContract } from "./common";

async function getEther(contractAddr, artifact, etherReq, walletAddr) {
    if (typeof window.ethereum != undefined) {
        await requestAccount();
        
        const faucetContract = getContract(contractAddr, artifact);
        try {
            console.log(`Requested Ether: ${etherReq}`);
            console.log(`Wallet Address: ${walletAddr}`);

            let amount = ethers.utils.parseEther(etherReq);
            let transaction = await faucetContract.getEther(walletAddr, amount);

            let receipt = await transaction.wait();
            console.log(receipt);
        }
        catch (err) {
            console.log(err);
        }
    }
}

async function donateEther(contractAddr, artifact, etherDonate) {
    if (typeof window.ethereum != undefined) {
        await requestAccount();

        const faucetContract = getContract(contractAddr, artifact);
        try {
            let amount = ethers.utils.parseEther(etherDonate);
            let transaction = await faucetContract.donate({ value: amount });

            let receipt = await transaction.wait();
            console.log(receipt);

        }
        catch (err) {
            console.log(err);
        }
    }
}



    

async function processPayment(contractAddr, artifact, etherDonate,name, salary, location, localCurrency, settlementCurrency, walletAddress, frequency ) {
    console.log("inside process payment");
    if (typeof window.ethereum != undefined) {
        await requestAccount();

        const faucetContract = getContract(contractAddr, artifact);
        try {
            console.log("name : "+name);
            console.log("salary :"+salary);
            console.log("location :"+location);
            console.log("localCurrency :"+localCurrency);
            console.log("settlementCurrency :"+settlementCurrency);
            console.log("walletAddress : "+walletAddress);
            console.log("frequency : "+frequency);


            let current = new Date();
            let startTime = new Date(current.getTime() + 86400000);
            

            let startTimestamp = Math.floor(startTime.getTime() / 1000);

            // let transaction = await faucetContract.greet();
            let transaction = await faucetContract.createCompensation(walletAddress , name, salary, location, localCurrency, settlementCurrency, frequency);
            // let transaction = await faucetContract.donate({ value: amount });

            let receipt = await transaction.wait();
            

            let streamId = receipt.events[2].args[0].toString();
            console.log(streamId);
            console.log(receipt);

        }
        catch (err) {
            console.log(err);
        }
    }
}

export { getEther, donateEther, processPayment }