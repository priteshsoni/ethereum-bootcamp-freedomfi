import { useState } from 'react';

import * as constants from "../constants";
import { TextField, Button, Typography, Divider } from '@material-ui/core';

import Payroll from "../abis/Payroll.json";
import { getEther, donateEther, processPayment, checkBalanceForStream, withdrawlForStream } from "../utils";

function Withdrawl() {
    const [EmployeeID, setEmployeeID] = useState();
    const [status, setStatus] = useState();

    

    // async function handleGetEther() {
    //     // setRequestLoading(true);
    //     await getEther(constants.FAUCET_ADDR, EthereumFaucet, etherReq, walletAddr);
    //     setRequestLoading(false);
    // }

    async function withdrwalForEmployee() {
        // setDonateLoading(true);
        setStatus("Loading..");
        console.log("calling withdrwalForEmployee");
        let status = await withdrawlForStream(constants.PAYROLL_ADDR, Payroll, EmployeeID);
        // setDonateLoading(false);
        console.log("balance : "+status);
        // setDonateLoading(false);
        setStatus("Transaction completed : "+status);
    }

    // async function handleDonateEther() {
    //     setDonateLoading(true);
    //     await donateEther(constants.FAUCET_ADDR, EthereumFaucet, etherDonate);
    //     setDonateLoading(false);
    // }

    return (
        <div className="App" style={{ padding: "50px" }}>
            <Typography variant="h4">
               FreedomFi
            </Typography>

           
            <TextField fullWidth onChange={e => setEmployeeID(e.target.value)} label=" Employee ID" /><br /><br />
           

            <Button onClick={withdrwalForEmployee} variant="contained" color="primary">
                Withdraw
            </Button><br /><br /><br />

            <Divider light /><br /><br />
            <p>{status}</p>
           
        </div>
    );
}

export default Withdrawl;