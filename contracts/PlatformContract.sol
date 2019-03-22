pragma solidity >=0.4.22 <0.6.0;

contract VotingContract {

    
    struct User {
        mapping (Item => uint) items; 
        uint8 money;
    }
    
    struct Item {
        uint8 relatedGameId; // 
        uint price;
        uint selledCount;
    }

    struct publisher {
        mappint (address => Item) relesedItem;
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

    }

    function buyItem() {

    }

    function queryItem() {

    } 
}
