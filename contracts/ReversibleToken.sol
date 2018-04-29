pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ReversibleToken is ERC20 {

    using SafeMath for uint;

    struct Transaction {
        uint amount;
        uint timestamp;
        address to;
        address from;
        bool confirmed;
    }

    ERC20 public token;

    uint256 totalSupply_;
    uint public escrow;

    uint constant public REVERSIBLE_TIMEFRAME = 30 days;

    Transaction[] public transfers;
    mapping (address => uint) private balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    event Reversed(uint transaction); // @todo more info
    event Confirmed(uint transaction);

    constructor(ERC20 _token) public {
        token = _token;
    }

    function deposit(uint amount) external {
        require(token.transferFrom(msg.sender, address(this), amount));
        balances[msg.sender] = balances[msg.sender].add(amount);
        totalSupply_.add(amount);
    }

    function withdraw(uint amount) external {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply_.sub(amount);
        require(token.transfer(msg.sender, amount));
    }

    function reverse(uint transaction) external {
        require(transfers[transaction].timestamp >= now + REVERSIBLE_TIMEFRAME);
        require(transfers[transaction].from == msg.sender);

        Transaction storage transfer = transfers[transaction];

        escrow = escrow.sub(transfer.amount);
        balances[transfer.from] = balances[transfer.from].add(transfer.amount);

        delete transfers[transaction];
        emit Reversed(transaction);
    }

    function confirm(uint transaction) external {
        require(transfers[transaction].timestamp < now + REVERSIBLE_TIMEFRAME);
        require(!transfers[transaction].confirmed);

        transfers[transaction].confirmed = true;

        Transaction storage transfer = transfers[transaction];
        escrow = escrow.sub(transfer.amount);
        balances[transfer.to] = balances[transfer.to].add(transfer.amount);
        emit Confirmed(transaction);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0));
        require(value <= balances[from]);
        require(value <= allowed[from][msg.sender]);
        transfer(from, to, value);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        transfer(msg.sender, to, value);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function totalSupply() public view returns (uint) {
        return totalSupply_;
    }

    function transfer(address from, address to, uint amount) internal {
        balances[from] = balances[from].sub(amount);
        escrow = escrow.add(amount);

        Transaction memory transfer = Transaction({
            amount: amount,
            timestamp: now,
            to: to,
            from: from,
            confirmed: false
        });

        transfers.push(transfer);

        emit Transfer(from, to, amount);
    }
}
