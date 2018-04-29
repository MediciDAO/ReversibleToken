pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ReversibleToken is ERC20 {

    using SafeMath for uint;

    ERC20 public token;

    mapping (address => uint) private balances;

    function ReversibleToken(ERC20 _token) public {
        token = _token;
    }

    function deposit(uint amount) external {
        require(token.transferFrom(msg.sender, address(this), amount));
        balances[msg.sender] = balances[msg.sender].add(amount);
    }

    function withdraw(uint amount) external {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        require(token.transfer(msg.sender, amount));
    }

}
