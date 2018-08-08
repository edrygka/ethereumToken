pragma solidity ^0.4.24;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  
  struct Customer {
      uint256 balance;
      uint256 lockTime;
      uint256 lockedTokens;
  } 

  mapping(address => Customer) internal balances;

  uint256 internal totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  
  function setLockTime(address _owner, uint256 _lockTime, uint _lockedTokens) internal returns (bool){
    balances[_owner].lockTime = balances[_owner].lockTime.add(_lockTime);
    balances[_owner].lockedTokens = balances[_owner].lockedTokens.add(_lockedTokens);
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender].balance);
    require(_to != address(0));
    uint256 free = balances[msg.sender].balance - balances[msg.sender].lockedTokens;// get tokens that had't been locked
    if(free <= _value){ // if it is enough - transaction performed basicly
      require(balances[msg.sender].lockTime <= now);
    } 
    
    balances[msg.sender].balance = balances[msg.sender].balance.sub(_value);
    balances[_to].balance = balances[_to].balance.add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner].balance;
  }
  
  function getLockTime(address _owner) public view returns (uint256){
    return balances[_owner].lockTime;
  }
  
  function getLockedTokens(address _owner) public view returns (uint256){
    return balances[_owner].lockedTokens;
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
    require(_value <= allowed[_from][msg.sender]);
    require(_value <= balances[_from].balance);
    require(_to != address(0));
    uint256 free = balances[msg.sender].balance - balances[msg.sender].lockedTokens;// get tokens that had't been locked
    
    if(free <= _value){ // if it is not enough - check locktime of tokens and execute tx the same
      require(balances[msg.sender].lockTime <= now);
    } 
    balances[_from].balance = balances[_from].balance.sub(_value);
    balances[_to].balance = balances[_to].balance.add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256){
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool){
    allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool){
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who].balance);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who].balance = balances[_who].balance.sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  function mint(address _to, uint256 _amount)hasMintPermission canMint public returns (bool){
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to].balance = balances[_to].balance.add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }
  
  function mintLockedTokens(address _to, uint256 _amount, uint _lockTime) hasMintPermission canMint public returns (bool){
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to].balance = balances[_to].balance.add(_amount);
    setLockTime(_to, _lockTime, _amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  } 
  
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

contract TestToken is MintableToken, BurnableToken { // token is burnable in compliance with the whitepaper
    string public constant name = "My Test Token";
    string public constant symbol = "MTT";
    uint8 public  constant decimals = 18;
    
}