// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract Payroll {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
//    using Chainlink for Chainlink.Request;
    
     address public owner;

    /**
     * @notice Counter for new compensation ids.
     */
    Counters.Counter public compIdCounter;
    Counters.Counter public streamIdCounter;

    constructor() {
        owner  = msg.sender;
    }


    /**
     * @dev Throws if the caller is not the sender of the recipient of the stream.
     */
    modifier onlyRecipient(uint256 streamId) {
        require(
             msg.sender == streams[streamId].recipient,
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
    mapping(uint256 => Stream) private streams;
    
    mapping(uint256 => Compensation) private comp;



      struct Stream {
        address recipient;
        address sender;
       // uint256 deposit;
        uint256 prevTransacTime;
       // uint256 stopTime;
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
        uint256 balance,
        uint256 prevTransacTime
    );

    /**
     * @notice Emits when the recipient of a stream withdraws a portion or all their pro rata share of the stream.
     */
    event WithdrawFromStream(uint256 indexed streamId, address indexed recipient);

    /**
     * @notice Emits when a stream is successfully cancelled and tokens are transferred back on a pro rata basis.
     */
    event CancelStream(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 balance
    );
    
    event Greet(string message);
    
   function greet() public {
        emit Greet("Hello World!");
    }

function balanceOf( uint256 streamId) public view streamExists(streamId) returns (uint256 balance) {
        require(((msg.sender == owner) || (msg.sender == streams[streamId].recipient)), "Not an valid user");
  
        Stream memory stream = streams[streamId];
        uint256 elapsedTime = elapsedTimeFor(streamId);
        uint256 due = elapsedTime.mul(stream.rate);

        //calculate the no of two week long instances elapsed between the start time and current time
        balance += due;

        return balance;
        
    }

function elapsedTimeFor(uint256 streamId) private view returns (uint256 delta) {
    Stream memory stream = streams[streamId];
    
    // Before the start of the stream
    if (block.timestamp <= stream.prevTransacTime) return 0;
    
    // During the stream
    if (block.timestamp > stream.prevTransacTime) {
            return (block.timestamp - stream.prevTransacTime) % 14 days;
    }

    
}    

function createCompensation(
        address recipient,
        uint256 empStartTime,
        string memory name,
        uint256 annualSalary,
        string memory country,
        string memory localCurrency,
        string memory settlementCurrency,
        uint256 frequency
    ) external returns(uint256 compId){
        compIdCounter.increment();    
        compId = compIdCounter.current();

        uint256 paycheck = annualSalary/26;
        //1 USD = 20 pesos 
        uint256 currConvRate = 1; // requestVolumeData(currency);

        //to calculate the paycheck in dollars 
        paycheck = paycheck/currConvRate;

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

        createStream(recipient,paycheck,empStartTime);

        // return 1;
    }



function createStream(
            address recipient,
            uint256 rate,
            uint256 prevTransacTime
    ) internal returns (uint256 streamId) {
        
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
        
        // Rate Per second
       // uint256 rate = deposit.div(duration);
        
        streams[currentStreamId] = Stream({
           rate: rate,
           recipient: recipient,
           sender: msg.sender,
           prevTransacTime: block.timestamp,
           balance: 0,
           isEntity: true
        });
        

        
        emit CreateStream(currentStreamId, msg.sender, recipient, rate, prevTransacTime);
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

        // this will withdraw the entire balance 
        (bool success, ) = payable(stream.recipient).call{value: balance, gas: 100000}("");
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

}