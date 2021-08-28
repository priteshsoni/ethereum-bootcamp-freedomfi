import { useState } from 'react';

import * as constants from "../constants";
import { TextField, Button, Typography, Divider } from '@material-ui/core';

import Payroll from "../abis/Payroll.json";
import { getEther, donateEther, processPayment, checkBalanceForStream } from "../utils";

function CheckBalance() {
    const [EmployeeID, setEmployeeID] = useState();
    const [status, setStatus] = useState();

    

    // async function handleGetEther() {
    //     // setRequestLoading(true);
    //     await getEther(constants.FAUCET_ADDR, EthereumFaucet, etherReq, walletAddr);
    //     setRequestLoading(false);
    // }

    async function checkBalance() {
        // setDonateLoading(true);
        setStatus("Loading..")
        console.log("calling checkBalance");
        let balance = await checkBalanceForStream(constants.PAYROLL_ADDR, Payroll, EmployeeID);
        console.log("balance : "+balance);
        // setDonateLoading(false);
        setStatus("Balance : "+balance);
    }

    // async function handleDonateEther() {
    //     setDonateLoading(true);
    //     await donateEther(constants.FAUCET_ADDR, EthereumFaucet, etherDonate);
    //     setDonateLoading(false);
    // }

    return (
        <div className="App" style={{ padding: "50px" }}>
            <Typography variant="h4">
                Freedom Fi
            </Typography>

           
            <TextField fullWidth onChange={e => setEmployeeID(e.target.value)} label=" Employee ID" /><br /><br />
           

            <Button onClick={checkBalance} variant="contained" color="primary">
                Check Balance
            </Button><br /><br /><br />

            <Divider light /><br /><br />

            <p>{status}</p>   
        </div>
    );
}

export default CheckBalance;