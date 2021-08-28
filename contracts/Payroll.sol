// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Payroll {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    //  using Chainlink for Chainlink.Request;
    AggregatorV3Interface internal priceFeedAUD;
    AggregatorV3Interface internal priceFeedEUR;
    AggregatorV3Interface internal priceFeedGBP;
    AggregatorV3Interface internal priceFeedJPY;
    AggregatorV3Interface internal priceFeedUSDC;
    
    // Price oracles adress for forex rates (Rinkeby)
    address internal AUD = 0x21c095d2aDa464A294956eA058077F14F66535af;
    address internal EUR = 0x78F9e60608bF48a1155b4B2A5e31F32318a1d85F;
    address internal GBP = 0x7B17A813eEC55515Fb8F49F2ef51502bC54DD40F;
    address internal JPY = 0x3Ae2F46a2D84e3D5590ee6Ee5116B80caF77DeCA;
    address internal USDC = 0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB;
    
    // Common constants
    uint256 internal paymentPeriod = 31536000;
    uint256 internal precision = 10**18;
     
    uint internal eth_usd = 3275;
         
    address public owner;
    
    // ERC-20 on Rinkeby
    address USDCContract = 0xD92E713d051C37EbB2561803a3b5FBAbc4962431;
    address fakeDAI = 0x5eD8BD53B0c3fa3dEaBd345430B1A3a6A4e8BD7C;
    address recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    /**
     * @notice Counter for new compensation ids.
     */
    Counters.Counter public compIdCounter;
    Counters.Counter public streamIdCounter;
    
    
    constructor() {
        owner  = msg.sender;
        priceFeedAUD = AggregatorV3Interface(AUD);
        priceFeedEUR = AggregatorV3Interface(EUR);
        priceFeedGBP = AggregatorV3Interface(GBP);
        priceFeedJPY = AggregatorV3Interface(JPY);
        priceFeedUSDC = AggregatorV3Interface(USDC);
    }
    
    
    modifier onlyRecipient(uint256 streamId) {
        require(
             ((msg.sender == owner) || (msg.sender == streams[streamId].recipient)),
            "caller is not the recipient of the stream"
        );
        _;
    }
    
    
    /**
     * @dev Throws if the id does not point to a valid stream.
     */
    modifier streamExists(uint256 streamId) {
        require(streams[streamId].isEntity, "stream does not exist");
        _;
    }
    
    
    /**
     * @dev The stream objects identifiable by their unsigned integer ids.
     */
    mapping(uint256 => Stream) public streams;
    
    mapping(uint256 => Compensation) public comp;
      struct Stream {
        address recipient;
        address sender;
        string localCurrency;
        string settlementCurrency;
        uint256 prevTransacTime;
        uint256 rate;
        uint256 balance;
        bool isEntity;
    }
    
    struct Compensation{
        address recipient;
        uint256 empStartTime;
        string name;
        uint256 annualSalary;
        string country;
        string localCurrency;
        string settlementCurrency;
        uint256 frequency;
    }
    
    //modify the params 
    /**
     * @notice Emits when a stream is successfully created.
     */
    event CreateStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        string localCurrency,
        string settlementCurrency,
        uint256 balance,
        uint256 prevTransacTime
    );
    
    
    /**
     * @notice Emits when the recipient of a stream withdraws a portion or all their pro rata share of the stream.
     */
    event WithdrawFromStream(uint256 indexed streamId, address indexed recipient);
    
    /**
     * @notice Emits when someone checks the balance of a stream
     */
    event BalanceOf(uint256 indexed streamId, uint256 balance);
    
    /**
     * @notice Emits when a stream is successfully cancelled and tokens are transferred back on a pro rata basis.
     */
    event CancelStream(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 balance
    );
    
    function balanceOf( uint256 streamId) public streamExists(streamId) returns (uint256 balance) {
        require(((msg.sender == owner) || (msg.sender == streams[streamId].recipient)), "Not an valid user");
  
        Stream memory stream = streams[streamId];
        uint256 elapsedTime = elapsedTimeFor(streamId);
        uint256 due = elapsedTime.mul(stream.rate);
        
        // setPricebySymbol(streams[streamId].settlementCurrency);
        
        uint256 currConvRate = uint256(getLatestPrice(stream.settlementCurrency)); 
        
        // to calculate the paycheck in dollars 
        // exchange rate is returned in 8 digit precision
        due = due * 10**8/currConvRate;
        //calculate the no of two week long instances elapsed between the start time and current time
        balance += due;
        
        emit BalanceOf(streamId, balance);
        return balance;
        
    }
    /* This function returns the toal number of pay periods elapsed since the most recent withdrawal*/
    function elapsedTimeFor(uint256 streamId) private view returns (uint256 delta) {
    Stream memory stream = streams[streamId];
    
    // Before the start of the stream
    if (block.timestamp <= stream.prevTransacTime) return 0;
    
    // This function returns 
    if (block.timestamp > stream.prevTransacTime) {
            //return (block.timestamp - stream.prevTransacTime) % 1 seconds;
            return (block.timestamp - stream.prevTransacTime);
    }
    
    }    
    
    function createCompensation(
        address recipient,
        //uint256 empStartTime,
        uint256 deposit,
        string memory name,
        uint256 annualSalary,
        string memory country,
        string memory localCurrency,
        string memory settlementCurrency,
        uint256 frequency
    ) external returns(uint256 compId){
        // Requires
        // require(deposit == msg.value, "Deposit not received"); 
        require(recipient != address(0x00), "Stream to the zero address");
        require(recipient != address(this), "Stream to the contract itself");
        require(recipient != msg.sender, "Stream to the caller");
        require(deposit > 0, "Deposit is less that or equal to zero");
        
        compIdCounter.increment();    
        compId = compIdCounter.current();
        uint256 empStartTime = block.timestamp;
        uint256 paycheck = annualSalary*precision/paymentPeriod;
        comp[compId] = Compensation ({
            recipient : recipient,
            empStartTime: empStartTime,
            name : name,
            annualSalary : annualSalary,
            country : country,
            localCurrency : localCurrency,
            settlementCurrency : settlementCurrency,
            frequency : frequency
        });
        
        uint256 newStreamId = createStream(recipient, paycheck,empStartTime, localCurrency, settlementCurrency);
        return compId;
    }
    // Create payment stream for the employee
    function createStream(
            address recipient,
            uint256 rate,
            uint256 prevTransacTime,
            string memory localCurrency,
            string memory settlementCurrency
    ) private returns (uint256 streamId) {
        
        // Requires
        // require(deposit == msg.value, "Deposit not received"); 
        require(recipient != address(0x00), "Stream to the zero address");
        require(recipient != address(this), "Stream to the contract itself");
        require(recipient != msg.sender, "Stream to the caller");
        // require(deposit > 0, "Deposit is less that or equal to zero");
        require(prevTransacTime >= block.timestamp, "Start time before block timestamp");
        //require(stopTime > startTime, "Stop time before start time");
        
        //uint256 duration = stopTime.sub(startTime);
        
      //  require(deposit >= duration, "Deposit smaller than duration");
      //  require(deposit.mod(duration) == 0, "Deposit is not a multiple of time delta");
        
        streamIdCounter.increment();    
        uint256 currentStreamId = streamIdCounter.current();
        
        
        streams[currentStreamId] = Stream({
           rate: rate,
           recipient: recipient,
           localCurrency : localCurrency, 
           settlementCurrency : settlementCurrency,
           sender: msg.sender,
           prevTransacTime: block.timestamp,
           balance: 0,
           isEntity: true
        });
        
        
        emit CreateStream(currentStreamId, msg.sender, recipient, localCurrency, settlementCurrency, rate, prevTransacTime);
        return currentStreamId;
    }
    /**
     *  @notice Withdraws from the contract to the recipient's account.
     *  @dev Throws if the id does not point to a valid stream.
     *  Throws if the calelr is not the sender or the recipient of the stream.
     *  Throws if there is a token transfer failure.
     *  @param streamId The id of the stream to withdraw tokens from.  
     */
    function withdrawFromStream(
            uint256 streamId
    )  external 
        streamExists(streamId)
        onlyRecipient(streamId) {
        
        Stream memory stream = streams[streamId];
        uint256 balance = balanceOf(streamId);
        
        require(balance > 0, "Available balance is 0");
        
        // this will withdraw the entire balance in ether
        // (bool success, ) = payable(stream.recipient).call{value: balance/eth_usd, gas: 100000}("");
        
        // this will withdraw the entire balance in USD stablecoin
        IERC20 token = IERC20(fakeDAI);
        (bool success) = token.transfer(recipient, balance);
        
        require(success, "Transaction failed");
        
        streams[streamId].balance = 0;
        streams[streamId].prevTransacTime = block.timestamp;
        
        emit WithdrawFromStream(streamId, stream.recipient);
    }
    
    
    /**
    * @notice Cancels the stream and transfers the tokens back on a pro rata basis.
    * @dev Throws if the id does not point to a valid stream.
    *  Throws if the caller is not the sender or the recipient of the stream.
    *  Throws if there is a token transfer failure.
    * @param streamId The id of the stream to cancel.
    */
    function cancelStream( uint256 streamId)  external 
    streamExists(streamId)
    onlyRecipient(streamId) {
    Stream memory stream = streams[streamId];
    uint256 recipientBalance = balanceOf(streamId);
    //Question - why are we deleteing the streams[streamId] even before validating recipient's balance? 
    delete streams[streamId];
    if (recipientBalance > 0) {
        (bool success, ) = payable(stream.recipient).call{value: recipientBalance, gas: 100000}("");
        require(success, "Transaction failed");
    }
    emit CancelStream(streamId, stream.recipient, recipientBalance);
} 
   
    
    address internal symbol;
    
    
    /**
     * Get latest price for one of the four currencies
     * AUD, EUR, GBP, JPY
     */
    // function getPricebySymbol(string memory _currency) public returns (int) {
        function setPricebySymbol(string memory _currency) public {
        if (hashCompareWithLengthCheck(_currency,"AUD")) {
            symbol = AUD;
        } else if (hashCompareWithLengthCheck(_currency,"EUR")) {
            symbol = EUR;
        } else if (hashCompareWithLengthCheck(_currency,"GBP")) {
            symbol = GBP;
        } else if (hashCompareWithLengthCheck(_currency,"JPY")) {
            symbol = JPY;
        } else {
            symbol = USDC;
        }
        // priceFeed = AggregatorV3Interface(symbol);
        // return getLatestPrice();
    }
    /**
     * Returns the latest price
     * Need to divide by 10**8 to get the final rate
     */
    function getLatestPrice(string memory _currency) public view returns (int) {
        AggregatorV3Interface priceFeed;
        if (hashCompareWithLengthCheck(_currency,"AUD")) {
            priceFeed = priceFeedAUD;
        } else if (hashCompareWithLengthCheck(_currency,"EUR")) {
            priceFeed = priceFeedEUR;
        } else if (hashCompareWithLengthCheck(_currency,"GBP")) {
            priceFeed = priceFeedGBP;
        } else if (hashCompareWithLengthCheck(_currency,"JPY")) {
            priceFeed = priceFeedJPY;
        } else {
            priceFeed = priceFeedUSDC;
        }
        
        // now retreivve the latest forex rate
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
    
    // Utility
    function hashCompareWithLengthCheck(string memory a, string memory b) internal pure returns (bool) {
    if(bytes(a).length != bytes(b).length) {
        return false;
    } else {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
}