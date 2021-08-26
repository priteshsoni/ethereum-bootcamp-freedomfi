import React from "react"
// const { ethers } = require("hardhat");



class InputForm extends React.Component {
    constructor(props) {
      super(props);
      this.state = {value: ''};
      this.handleChange = this.handleChange.bind(this);

      this.handleSubmit = this.handleSubmit.bind(this);
    }
  
    handleChange(event) {    this.setState({value: event.target.value});  }
    handleSubmit(event) {
     
      var comp = document.getElementById("comp").value;
      var address = document.getElementById("address").value;
      var country = document.getElementById("country").value;
      var freq = document.getElementById("freq").value;
      var currency = document.getElementById("currency").value;

      alert('comp: ' + comp);
      alert('address: ' + address);
      alert('country: ' + country);
      alert('freq: ' + freq);
      alert('currency: ' + currency);
      document.getElementById("form1").reset();
    //   validationEvent();
      event.preventDefault();
    }
  
    render() {
      return (
        <form id="form1" onSubmit={this.handleSubmit}>
          <br></br>  
          <label>
            Annual Compensation:
            <input type="text"  id="comp" onChange={this.handleChange} /> 
          </label>
          <br></br>
          <label>
            Eth Wallet Address:
            <input type="text"  id="address" onChange={this.handleChange} /> 
          </label>
          <br></br>
          <label>
            Country of Employement:
            <input type="text"  id="country" onChange={this.handleChange} /> 
          </label>
          <br></br>
          <label>
            Frequency:
            <input type="text" id="freq" onChange={this.handleChange} /> 
          </label>
          <br></br>
          <label>
            Currency:
            <input type="text"  id="currency" onChange={this.handleChange} /> 
            <br></br>
          </label>
          <br></br>
          <input type="submit" value="Submit" />
          <br></br>
        </form>
      );
    }
    validationEvent(){
        alert('hello');
    }
    /*SmartContract (){
        let SampleContract, sampleContract;
    
        
            SampleContract =  ethers.getContractFactory("SampleContract");
            sampleContract =  SampleContract.deploy();
            sampleContract.greet();
    }*/

  }

  export default InputForm;