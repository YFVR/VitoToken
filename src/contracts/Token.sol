pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./SafeMath.sol";

contract Token is Ownable {
    using SafeMath for uint;

    string public name = "Virtual Token";
    string public symbol = "VITO";
    uint8 public decimals = 4;
    uint256 public totalSupply = 100000000000000;

    mapping (address => Balance) private _balances;
    address[] private _hodlers;

    mapping (address => mapping (address => uint256)) private allowed;

    //0.6 * 10 ** 4 (decimals)
    uint256 public pa = 600; //6% pa
    uint256 public rate = 16; //per day

    uint256 private _min = 50000 * 10 ** decimals;

    uint256 public _start;

    struct Balance {
        uint256 timestamp;
        uint256 amount;
        uint index;
    }

    constructor () public {
        _start = now;
        insertHodler(msg.sender);

        _balances[msg.sender].timestamp = _start;
        _balances[msg.sender].amount = totalSupply;
    }

    function balanceOf(address who) public view returns (uint256) {
        if (who == owner) {
            uint256 incirculation = getInCirculation();
            return totalSupply.sub(incirculation);
        } else {
            return getBalanceAtTime(who, now);
        }
    }

    function transfer(address to, uint256 value) public returns (bool) {
        uint256 timestamp = now;
        //require(getBalanceAtTime(msg.sender, timestamp) >= value, "Insufficient balance");

        if (!isHodler(to)) {
            insertHodler(to);
        }
        
        if (msg.sender == owner) {
            _balances[owner].amount = _balances[owner].amount.sub(value);
        } else {
            _balances[msg.sender].timestamp = timestamp;
            _balances[msg.sender].amount = getBalanceAtTime(msg.sender, timestamp).sub(value);
        }

        if (to == owner) {
            _balances[owner].amount = _balances[owner].amount.add(value);
        } else {
            _balances[to].timestamp = timestamp;
            _balances[to].amount = getBalanceAtTime(to, timestamp).add(value);

            //emit Transfer(msg.sender, to, value);
            //_balances[to] = Balance(timestamp, value, 0); //_balances[to].amount.add(value);
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

    function delta(uint256 from, uint256 to) public pure returns (uint256) {
        require(to >= from, "To must be greater than from");
        return to - from;
    }

    function calcInterest(uint256 amount, uint256 _days) public view returns (uint256) {
        uint256 perYear = (_days * uint256(10) ** decimals) / 365;
        return (amount * pa * perYear) / uint256(10) ** (decimals * 2);
    }

    function getBalanceAtTime(address who, uint256 timestamp) public view returns(uint256) {
        if (_balances[who].amount > 0) {
            if (_balances[who].amount < _min) {
                return _balances[who].amount;
            } else {
                uint256 _delta = delta(_balances[who].timestamp, timestamp);
                _delta = _delta.div(24 * 60 * 60);

                return _balances[who].amount + calcInterest(_balances[who].amount, _delta);
            }
        }
    
        return 0;
    }

    function getInCirculation() public view returns(uint256) {
        uint256 cumlative = 0;
        uint256 timestamp = now;

        for (uint256 i = 0; i < _hodlers.length; i++) {
            address who = _hodlers[i];

            if (who != owner) {
                uint256 balance = getBalanceAtTime(who, timestamp);
                cumlative = cumlative.add(balance);
            }
        }

        return cumlative;
    }

    function isHodler(address who) public view returns(bool) {
        if(_hodlers.length == 0) return false;
        return (_hodlers[_balances[who].index] == who);
    }

    function insertHodler(address who) public returns(uint) {
        if(!isHodler(who)) {
            _balances[who].index = _hodlers.push(who) - 1;
            return _hodlers.length - 1;
        }

        return 0;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}