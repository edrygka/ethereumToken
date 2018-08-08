# ethereumToken

It is not just simple ERC20 token with basic functions, classic mapping in Standart token looks like 
"mapping (address => uint) balances;" no
I created structure struct 
Customer {
    uint256 balance;
    uint256 lockTime;
    uint256 lockedTokens;
}
mapping(address => Customer) internal balances;

So in that way every holder of this token can get on one address locked tokens(on some everage time) and free tokens(he can transfer them any moment he want).