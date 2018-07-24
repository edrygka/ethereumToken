pragma solidity ^0.4.24;
import "./Ownable.sol";
import "./Token.sol";
import "./SafeMath/SafeMath.sol";


contract Crowdsale is Ownable {

  using SafeMath for uint;

  address multisig;
  uint restrictedPercent;
  address restricted;
  Token public token = new Token();

  uint start;
  uint period;
  uint rate;

  constructor() public {
    multisig = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;
    restricted = 0xb3eD172CC64839FB0C0Aa06aa129f402e994e7De;
    restrictedPercent = 40;
    rate = 100000000000000000000;
    start = 1500379200;
    period = 28;
  }

  modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }

  function createTokens() public saleIsOn payable {
    multisig.transfer(msg.value);
    uint tokens = rate.mul(msg.value).div(1 ether); 

    // calculate price discount if paid earlier
    uint bonusTokens = 0;
    if(now < start + (period * 1 days).div(4)) {
      bonusTokens = tokens.div(4);
    } else if(now >= start + (period * 1 days).div(4) && now < start + (period * 1 days).div(4).mul(2)) {
      bonusTokens = tokens.div(10);
    } else if(now >= start + (period * 1 days).div(4).mul(2) && now < start + (period * 1 days).div(4).mul(3)) {
      bonusTokens = tokens.div(20);
    }

    uint tokensWithBonus = tokens.add(bonusTokens);
    token.transfer(msg.sender, tokensWithBonus);
    uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
    token.transfer(restricted, restrictedTokens);
  }

  function() external payable {
    createTokens();
  }
}