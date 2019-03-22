pragma solidity >=0.4.22 <0.6.0;

contract VotingContract {

    /*    Normal user of the plantform:
          Items: the */
    struct User {
        address relatedAddress;
        mapping (Item => uint) items; 
        uint8 money;
        bool authority;
    }
    
    struct Item {
        address relatedAddress;
        uint8 relatedGameId; // 
        uint price;
        uint selledCount;
        bool repeatable;
        bool tradeable;
    }

    struct publisher {
        mapping (address => Item) relesedItem;
    }

    address public administrator;
    mapping(address => User) public users; // def regeister() 
    Item[] public items; // items can be selled

    constructor() public {
        administrator = msg.sender;
        users[administrator].banned = false;
    }

    function releaseItem() {

    }

    function deleteItem() {

    }

    function regeister() {
        require(msg.sender != administrator);
        users[msg.sender] = User(msg.sender, null, 0, true);
    }

    function addMoney (uint8 count) {
        require(msg.sender != administrator);
        users[msg.sender].money = users[msg.sender].money + count;
    }

    function buyItem() {

    }

    function tradeItem() {

    }

    function banPerson(address userAddress) {
        require(msg.sender == administrator);
        users[userAddress].authority = false;
    }

    function unbanPerson() {
        require(msg.sender == administrator);
        users[userAddress].authority = true;;
    }
}
