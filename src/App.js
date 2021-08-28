import './App.css';
import InputForm from './components/InputForm';
import CheckBalance from './components/CheckBalance';
import Withdrawl from './components/Withdrawl';
import RequestForm from './components/RequestForm';

import Tab from '@material-ui/core/Tab';
import Tabs from '@material-ui/core/Tabs';
import AppBar from '@material-ui/core/AppBar';

import { useState } from "react";

  function App() {
    const [tabValue, setTabValue] = useState(0);
  
    function a11yProps(index) {
      return {
        id: `tab-${index}`,
        'aria-controls': `tabpanel-${index}`,
      };
    }
  
    function handleTabChange(event, newValue) {
      setTabValue(newValue);
    }
  
  return (
    <div className="App">
    <AppBar position="static">
      <Tabs value={tabValue} onChange={handleTabChange} aria-label="Payment Streams">
        <Tab label="Add Employee" {...a11yProps(0)} />
        <Tab label="Check Balance" {...a11yProps(1)} />
        <Tab label="Withdraw" {...a11yProps(2)} />
      </Tabs>
    </AppBar>

    {tabValue === 0 && (<InputForm />)}
    {tabValue === 1 && (<CheckBalance />)}
    {tabValue === 2 && (<Withdrawl />)}

  </div>
  );
}

export default App;
