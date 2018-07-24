pragma solidity ^0.4.24;
import "./StandartToken.sol";

contract Token is StandardToken {
    
  string public constant name = "My Test Token";
   
  string public constant symbol = "MTT";
    
  uint32 public constant decimals = 18;
 
  uint256 public INITIAL_SUPPLY = 100000000 * 1 ether;
 
  constructor() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}