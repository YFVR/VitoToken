pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Token is IERC20, Ownable {
    using SafeMath for uint;

    function name() public view returns (string memory) {
        return "Virtual Token";
    }

    function symbol() public view returns (string memory) {
        return "VITO";
    }

    function decimals() public view returns (uint8) {
        return 18;
    }
    
    function totalSupply() external view returns (uint256) {
        return 100000000000000;
    }

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    constructor () public {
        _balances[msg.sender] = 100000000000000;
        emit Transfer(address(0), msg.sender, 100000000000000);
    }

    function balanceOf(address who) public view returns (uint256) {
        _balances[who];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(_balances[msg.sender] >= value, "Insufficient balance");

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(_balances[from] >= value, "Insufficient balance");
        require(_allowances[from][msg.sender] >= value, "Insufficient balance");
        
        _balances[from] = _balances[from].sub(value);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Invalid address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return 0;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}