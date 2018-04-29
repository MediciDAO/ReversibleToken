pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ReversibleToken is ERC20 {

    using SafeMath for uint;

    struct Transfer {
        uint amount;
        uint timestamp;
        address to;
        address from;
        bool confirmed;
    }

    ERC20 public token;

    uint public escrow;

    uint constant public REVERSIBLE_TIMEFRAME = 30 days;

    mapping (uint => Transfer) public transfers;
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

    function reverse(uint transaction) external {
        require(transfers[transaction].timestamp >= now + REVERSIBLE_TIMEFRAME);

        Transfer transfer = transfers[transaction];

        escrow = escrow.sub(transfer.amount);
        balances[transfer.from] = balances[transfer.from].add(transfer.amount);

        delete transfers[transaction];
    }

    function confirm(uint transaction) external {
        require(transfers[transaction].timestamp < now + REVERSIBLE_TIMEFRAME);
        require(!transfer[transaction].confirmed);

        transfers[transaction].confirmed = true;

        Transfer transfer = transfers[transaction];
        escrow = escrow.sub(transfer.amount);
        balances[transfer.to] = balances[transfer.to].add(transfer.amount);
    }

}
