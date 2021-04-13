pragma solidity >=0.5.16;

import './modules/ERC20Token.sol';
import './modules/Ownable.sol';

contract XBurger is ERC20Token, Ownable {
    mapping (address => bool) public isWhiteListed;
    event ChangedWhiteList(address indexed _user, bool _old, bool _new);

    constructor() public {
        name = 'XBurger';
        symbol = 'XBurger';
    }
    
    function setWhiteLists (address[] calldata _users, bool[] calldata _values) external onlyOwner {
        require(_users.length == _values.length, 'invalid parameters');
        for (uint i=0; i<_users.length; i++){
            _setWhiteList(_users[i], _values[i]);
        }
    }

    function setWhiteList (address _user, bool _value) external onlyOwner {
        require(isWhiteListed[_user] != _value, 'no change');
        _setWhiteList(_user, _value);
    }

    function _setWhiteList (address _user, bool _value) internal {
        emit ChangedWhiteList(_user, isWhiteListed[_user], _value);
        isWhiteListed[_user] = _value;
    }

    function mint(address to, uint value) external returns (bool) {
        require(isWhiteListed[msg.sender], "sender is not in whitelist");
        balanceOf[to] = balanceOf[to].add(value);
        totalSupply = totalSupply.add(value);
        emit Transfer(address(this), to, value);
        return true;
    }

    function burn(uint value) external returns (bool) {
        _transfer(msg.sender, address(0), value);
        return true;
    }
}
