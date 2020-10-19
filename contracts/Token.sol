pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Token is IERC20, Ownable {
    using SafeMath for uint;

    function name() public pure returns (string memory) {
        return "Virtual Token";
    }

    function symbol() public pure returns (string memory) {
        return "YFVR";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
    
    uint256 private constant _totalSupply = 100000000000000;
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    uint256 private _lockperiod;
    mapping (address => bool) private _whitelist;
    mapping (address => uint256) private _locks;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    constructor () public {
        _balances[msg.sender] = _totalSupply;
        _lockperiod = 30 days;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _balances[who];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(_balances[msg.sender] >= value, "Insufficient balance");

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);

        _locks[to] = now + _lockperiod;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(_balances[from] >= value, "Insufficient balance");
        require(_allowances[from][msg.sender] >= value, "Insufficient balance");
        require(canSpend(from), "Still in lock period");
        require(_whitelist[from] == true, "Not in white list");

        _balances[from] = _balances[from].sub(value);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);
        return true;
    }

    function canSpend(address spender) public view returns (bool) {
        return now > _locks[spender];
    }

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

    function updateWhiteList(address contractToWhitelist, bool isWhiteListed) public onlyOwner() {
        _whitelist[contractToWhitelist] = isWhiteListed;
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