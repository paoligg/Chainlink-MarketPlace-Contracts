// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Marketplace {
    AggregatorV3Interface private priceFeed;
    address public priceFeedAddress=0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address public stablePaoAddress=0xc5662eFC8F9a00Ac520f3aDBc2f555fFFEB6ff62;
    address public ethPaoAddress=0x90aFBde8c09E091103556dBE7E24416E0d82f861;

    uint256 public price = 0;

    constructor() {
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 currentPrice, , , ) = priceFeed.latestRoundData();
        return currentPrice;
    }

    function swapforETHToken(uint256 _amountToBuy) public  {
        // Get the current price of the token to buy from Chainlink
        uint256 currentPrice = uint256(getLatestPrice());
        require (currentPrice > 0, "Price is zero");
        uint256 amountToSell = (_amountToBuy * 10 ** 10 ) * currentPrice ;

        require(ERC20(stablePaoAddress).allowance(msg.sender, address(this)) >= amountToSell, "Insufficient allowance");
        require(ERC20(stablePaoAddress).transferFrom(msg.sender, address(this), amountToSell), "Transfer failed");
        ERC20(ethPaoAddress).transfer(msg.sender, _amountToBuy * 10 ** 18);
    }

    function swapforStableToken(uint256 _amountToBuy) public  {
        // Get the current price of the token to buy from Chainlink
        uint256 currentPrice = uint256(getLatestPrice());
        require (currentPrice > 0, "Price is zero");
        uint256 amountToSell = (_amountToBuy * 10 ** 26) / currentPrice;

        require(ERC20(ethPaoAddress).allowance(msg.sender, address(this)) >= amountToSell, "Insufficient allowance");
        require(ERC20(ethPaoAddress).transferFrom(msg.sender, address(this), amountToSell), "Transfer failed");
        ERC20(stablePaoAddress).transfer(msg.sender, _amountToBuy * 10 ** 18);
    }
}
