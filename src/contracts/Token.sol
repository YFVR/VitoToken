pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Token is IERC20, Ownable {
    using SafeMath for uint;

    string public name = "Virtual Token";
    string public symbol = "VITO";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000000000000;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private allowed;

    constructor () public {
        _balances[msg.sender] = totalSupply;

        emit Transfer(msg.sender, totalSupply);
    }

    function balanceOf(address who) public view returns (uint256) {
        _balances[who];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        uint256 timestamp = now;
        uint256 currentSenderBalance = balanceOf(msg.sender);
        require(currentSenderBalance >= value, "Insufficient balance");

        if (!isHodler(to)) {
            insertHodler(to);
        }
        
        if (msg.sender == owner) {
            _balances[owner].amount = _balances[owner].amount.sub(value);
        } else {
            _balances[msg.sender].timestamp = timestamp;
            
            _balances[msg.sender].amount = currentSenderBalance;
            _balances[msg.sender].amount = _balances[msg.sender].amount.sub(value);
        }

        if (to == owner) {
            _balances[owner].amount = _balances[owner].amount.add(value);
        } else {
            _balances[to].timestamp = timestamp;

            uint256 currentReceiverBalance = balanceOf(to);
            _balances[to].amount = currentReceiverBalance.add(value);
        }

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        uint256 timestamp = now;

        require(getBalanceAtTime(from, timestamp) >= value, "Insufficient balance");
        require(getBalanceAtTime(to, timestamp).add(value) >= getBalanceAtTime(to, timestamp), "Insufficient balance");
        require(allowed[from][msg.sender] >= value, "Insufficient balance");
        
        _balances[from].timestamp = now;
        _balances[from].amount = getBalanceAtTime(from, timestamp).sub(value);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

        _balances[to].timestamp = now;
        _balances[to].amount = getBalanceAtTime(to, timestamp).add(value);

        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Invalid address");

        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}