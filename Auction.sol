// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Auction smart contract for managing a timed bidding process
contract Auction {
    // Struct to store bidder information
    struct Bidder {
        address bidderAddress;
        uint256 amount;
    }

    // State variables
    address public immutable owner; // Contract deployer
    uint256 public startTime; // Auction start timestamp
    uint256 public stopTime; // Auction end timestamp
    uint256 public highestBid; // Current highest bid amount
    address public highestBidder; // Current highest bidder address
    mapping(address => uint256) public deposits; // Tracks total deposits per bidder
    Bidder[] public bidders; // Array of all bids
    bool public ended; // Flag to indicate if auction has ended
    uint256 constant MIN_BID_INCREMENT = 105; // 5% minimum increment (in percentage)
    uint256 constant EXTENSION_TIME = 10 minutes; // Extension time for last-minute bids
    uint256 constant COMMISSION = 2; // 2% commission on refunds

    // Events
    event NewOffer(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);
    event RefundProcessed(address indexed bidder, uint256 amount);
    event PartialRefundProcessed(address indexed bidder, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier isActive() {
        require(block.timestamp < stopTime && !ended, "Auction is not active");
        _;
    }

    modifier hasEnded() {
        require(block.timestamp >= stopTime || ended, "Auction is still active");
        _;
    }

    // Constructor to initialize the auction
    constructor() {
        owner = msg.sender;
        startTime = block.timestamp;
        stopTime = startTime + 7 days;
    }

    // Function to place a bid
    function bid() external payable isActive {
        // Ensure bid is greater than 0
        require(msg.value > 0, "Bid amount must be greater than 0");

        // Calculate minimum required bid (5% more than current highest)
        uint256 minRequiredBid = highestBid == 0 ? 0 : (highestBid * MIN_BID_INCREMENT) / 100;
        require(msg.value > minRequiredBid, "Bid must be at least 5% higher than current highest");

        // Update bidder's total deposit
        deposits[msg.sender] += msg.value;

        // Record the bid
        bidders.push(Bidder({bidderAddress: msg.sender, amount: msg.value}));

        // Update highest bid and bidder
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
        }

        // Extend auction if bid is placed in the last 10 minutes
        if (stopTime - block.timestamp < EXTENSION_TIME) {
            stopTime += EXTENSION_TIME;
        }

        // Emit event for new offer
        emit NewOffer(msg.sender, msg.value);
    }

    // Function to view the current winner
    function showWinner() external view returns (address, uint256) {
        return (highestBidder, highestBid);
    }

    // Function to view all bids
    function showOffers() external view returns (Bidder[] memory) {
        return bidders;
    }

    // Function to end the auction and process winner
    function endAuction() external onlyOwner hasEnded {
        require(!ended, "Auction already ended");
        ended = true;

        // Emit event for auction end
        emit AuctionEnded(highestBidder, highestBid);
    }

    // Function to process refunds for non-winners
    function refund() external onlyOwner hasEnded {
        require(ended, "Auction must be ended first");

        for (uint256 i = 0; i < bidders.length; i++) {
            address bidder = bidders[i].bidderAddress;
            // Skip the winner
            if (bidder == highestBidder) continue;

            uint256 amount = deposits[bidder];
            if (amount > 0) {
                // Calculate amount after 2% commission
                uint256 refundAmount = (amount * (100 - COMMISSION)) / 100;
                deposits[bidder] = 0; // Clear deposit before transfer
                (bool success, ) = bidder.call{value: refundAmount}("");
                require(success, "Refund transfer failed");
                emit RefundProcessed(bidder, refundAmount);
            }
        }
    }

    // Function for partial refund during active auction
    function partialRefund() external isActive {
        uint256 totalDeposited = deposits[msg.sender];
        require(totalDeposited > 0, "No deposits to refund");

        // Find the bidder's highest valid bid
        uint256 highestUserBid = 0;
        for (uint256 i = 0; i < bidders.length; i++) {
            if (bidders[i].bidderAddress == msg.sender && bidders[i].amount > highestUserBid) {
                highestUserBid = bidders[i].amount;
            }
        }

        // Calculate refundable amount (total deposited minus highest bid)
        uint256 refundable = totalDeposited - highestUserBid;
        require(refundable > 0, "No excess funds to refund");

        // Update deposit and process refund
        deposits[msg.sender] = highestUserBid;
        (bool success, ) = msg.sender.call{value: refundable}("");
        require(success, "Partial refund transfer failed");
        emit PartialRefundProcessed(msg.sender, refundable);
    }

    // Function to receive Ether (required for .call transfers)
    receive() external payable {
        revert("Use bid() to place a bid");
    }
}
