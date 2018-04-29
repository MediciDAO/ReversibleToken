pragma solidity ^0.4.18;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract EtherToken is StandardToken {

    event Deposited(address indexed sender, uint amount);
    event Withdrawn(address indexed sender, uint amount);

    function deposit() external payable {
        require(msg.value > 0);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint amount) external {
        require(amount > 0);

        balances[msg.sender] = balances[msg.sender].sub(amount);
        msg.sender.transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }
}
