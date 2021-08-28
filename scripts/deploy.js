const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const Payroll = await hre.ethers.getContractFactory("Payroll");
    const payrollDeploy = await Payroll.deploy();

    await payrollDeploy.deployed();
    console.log(`Payroll deployed to address: ${payrollDeploy.address}`);

    // We also save the contract's artifacts and address in the proper directory
    saveFrontendFiles(payrollDeploy);
}

function saveFrontendFiles(faucet) {
    const fs = require("fs");
    const contractsDir = __dirname + "/../src/abis";
  
    if (!fs.existsSync(contractsDir)) {
      fs.mkdirSync(contractsDir);
    }
  
    const FaucetArtifact = artifacts.readArtifactSync("Payroll");
  
    fs.writeFileSync(
      contractsDir + "/Payroll.json",
      JSON.stringify(FaucetArtifact, null, 2)
    );
}



main()
    .then(() => process.exit(0))
    .catch(error => {
        console.log(error);
        process.exit(1);
    });