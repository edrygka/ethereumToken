# ethereumToken

It is not just simple ERC20 token with basic functions, classic mapping in Standart token looks like 
"mapping (address => uint) balances;" no
I created structure struct: \n
Customer {\n
    uint256 balance;\n
    uint256 lockTime;\n
    uint256 lockedTokens;\n
}\n
mapping(address => Customer) internal balances;\n

So in that way every holder of this token can get on one address locked tokens(on some everage time) and free tokens(he can transfer them any moment he want).