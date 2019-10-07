pragma solidity ^0.5.6;

contract BiddingContract
{
    // Each bid will have a user(his address) and a bid amount
    struct Bid 
    {
        address payable user;// Each user will be paid back if someone else bids higher price
        uint bidAmount;
    }
    
    address payable  public owner;
    uint public startTime;// time when the contract is deployed by the auctioneer.
    uint public endauction;
    
    Bid[] AllBids;
    /*There can only be at most one constructor in a contract*/
    constructor() public 
    {
        AllBids.push(Bid(address(0), 0));
        owner=msg.sender;
    }
    /*
    modifier has the capability to change the behaviour of a function with
    which it is associated.
    */
    
    modifier onlyOwner()
    {
        require(owner==msg.sender,"only owner could see it");
        _;
    }
    
    /*function display()public returns(string memory) {
          
        if(block.timestamp<endauction) return string("time is not yet completed");
        else {
            uint lastIndex = AllBids.length - 1;
            emit bidWinner(AllBids[lastIndex].user, AllBids[lastIndex].bidAmount);
            return string("the winner is displayed");
        }
    }*/
     function () payable external 
     {
        startTime = block.timestamp; //time when block is created i.e contract is deployed.
        endauction = 40 + startTime; //the auction bidding period ends after (40 * 15secs ~ 10 minutes)
        uint lastIndex = AllBids.length - 1;//last index of AllBids array (index starts from 0)
        require(owner != msg.sender,"YOU ARE THE OWNER, YOU CANNOT BID IN THE AUCTION.  ");
        require(msg.value > AllBids[lastIndex].bidAmount,"YOUR BID MUST BE GREATER THAN PREVIOUS BID");
        require(startTime<endauction,"THE AUCTION HAS ENDED! BETTER LUCK NEXT TIME"); 
         
         /* In case if .send fails to send back the 
            previous bid amount to it's bidder,
            then the amount is sent to owner of the contract,
            to prevent money getting locked up in the smart contract.*/
            
        if(!AllBids[lastIndex].user.send(AllBids[lastIndex].bidAmount))
        {
            owner.transfer(msg.value );
            
        }
           AllBids.push(Bid(msg.sender,msg.value));// The highest bidder's address and bid goes into the contract.
           
           if(block.timestamp>endauction)
           { 
               owner.transfer(msg.value );// After the auction ends the highest bid is transferred to the owner
           }
    }
    /*The modifier 'onlyOwner' automatically checks the condition before executing the 'balance' function*/
    function balance() public view onlyOwner returns (uint) // only the owner can see the balance amount in the contract.
    {
        //require(manager == msg.sender,"Only the manager can call balance");
        return owner.balance;
    }
    
    function getTopBid() public view  returns (address, uint)// the last index of AllBids holds the highest bidder's details
    {
        uint lastIndex = AllBids.length - 1;
        return (AllBids[lastIndex].user, AllBids[lastIndex].bidAmount);
    }
    function getNumberOfBids() public view returns (uint) // returns the total number of bids placed in the auction
    {
        return AllBids.length-1;
    }
    function getBid(uint index) public view returns (address, uint) //returns the address and amount bid by the user specified by the index
    {
        return (AllBids[index].user, AllBids[index].bidAmount);
    }
}
