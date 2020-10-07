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
        return "YFVR";
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
        return _balances[who];
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

    // function approve(address spender, uint256 amount) external returns (bool) {
    //     require(spender != address(0), "Invalid address");

    //     _allowances[msg.sender][spender] = amount;
    //     emit Approval(msg.sender, spender, amount);
    //     return true;
    // }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}