import { useState } from 'react';

import * as constants from "../constants";
import { TextField, Button, Typography, Divider } from '@material-ui/core';

import Payroll from "../abis/Payroll.json";
import { getEther, donateEther, processPayment } from "../utils";


function InputForm() {
    const [name, setName] = useState();
    const [salary, setSalary] = useState();
    const [location, setLocation] = useState();
    const [localCurrency, setLocalCurrency] = useState();
    const [settlementCurrency, setSettlementCurrency] = useState();
    const [walletAddress, setWalletAddress] = useState();
    const [frequency, setFrequency] = useState();
    const [status, setStatus] = useState();

    

    // async function handleGetEther() {
    //     // setRequestLoading(true);
    //     await getEther(constants.FAUCET_ADDR, EthereumFaucet, etherReq, walletAddr);
    //     setRequestLoading(false);
    // }

    async function handlePaymentProcessing() {
        // setDonateLoading(true);
        setStatus("Loading...");
        console.log("calling processPayment");
        let streamID = await processPayment(constants.PAYROLL_ADDR, Payroll, "1", name, salary, location, localCurrency, settlementCurrency, walletAddress, frequency);
        console.log("streamId : "+streamID);
        // setDonateLoading(false);
        setStatus("Stream ID : "+streamID);
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

           
            <TextField fullWidth onChange={e => setName(e.target.value)} label="Employee Name" /><br /><br />
            <TextField fullWidth onChange={e => setSalary(e.target.value)} type="number" label="Employee Salary" /><br /><br />
            <TextField fullWidth onChange={e => setLocation(e.target.value)} label="Employee Country Location" /><br /><br />
            <TextField fullWidth onChange={e => setLocalCurrency(e.target.value)} label="Local currency" /><br /><br />
            <TextField fullWidth onChange={e => setSettlementCurrency(e.target.value)} label="Settlement Currency" /><br /><br />
            <TextField fullWidth onChange={e => setWalletAddress(e.target.value)} label="Employee Wallet Address" /><br /><br />
            <TextField fullWidth onChange={e => setFrequency(e.target.value)} type="number" label="Frequency" /><br /><br />


            <Button onClick={handlePaymentProcessing} variant="contained" color="primary">
                Submit
            </Button><br /><br /><br />

            <Divider light /><br /><br />

            <p>{status}</p>
        </div>
    );
}

export default InputForm;