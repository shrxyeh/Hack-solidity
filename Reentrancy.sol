//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*
Reentrancy
What is reentrancy?
- Remix code and demo
Preventative techniques
*/
contract EtherStore {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount);
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = _amount;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;
    uint256 _amount;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    fallback() external {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value > 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw(1 ether);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

// Solution

contract EtherStore {
    mapping(address => uint256) public balances;
    bool internal locked;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    modifier ReentrancyGuard() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function withdraw(uint256 _amount) public ReentrancyGuard {
        require(balances[msg.sender] >= _amount);
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = _amount;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
