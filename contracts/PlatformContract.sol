pragma solidity >=0.4.22 <0.6.0;

contract VotingContract {

    /*  Normal User who can buy or sell items
     *  items: number for each item he owned
     *  itemNumber: number of item he owned
     *  authority: whether this user can buy and sell items
     *  regeisted: this user has been regeisted
     */
    struct User {
        mapping(uint => uint) items; 
        uint money;
        bool authority;
        bool regeisted;
        uint ownedCount;
    }
    

    /*  Item released by publisher, can be selled by publisher or traded between user
     *  gameId: the item id of its related game 
     *  itmeId: Id of its self (increasing when releasing new item, start from 1 !!!)
     *  price:  price of item setted by publisher or administrator
     *  selledCount: recorded how many this items has been selled by publisher
     *  tradeCount: recorded how many this items has been traded between user
     *  repeatable: whether this item can be owned by user more than once (such as all game is unrepeatable)
     *  tradeable:  whether this item can be traded (both between publisher and user / user and user)
     */
    struct Item {
        uint gameId; 
        uint itemId; 
        uint price;
        uint selledCount;
        uint tradeCount;
        bool repeatable;
        bool tradeable;
    }

    /*  Publisher who can publish game or related Item
     *  Item: item published by this publisher
     *  authority: whether this publisher can publish game any more
     *  regeisted: this user has been regeisted
     */
    struct Publisher {
        mapping(uint => Item) relesedItems; 
        bool authority;
        bool regeisted;
        uint releasdCount;
    }

    address public administrator;
    mapping(address => User) public users; 
    mapping(address => Publisher) public publishers;
    Item[] public items; 

    constructor() public {
        administrator = msg.sender;
    }

    function regeisterPublisher() public {
        require(msg.sender != administrator && users[msg.sender].regeisted && publishers[msg.sender].regeisted);

        Publisher memory p;
        p.authority = true;
        p.regeisted = true;

        publishers[msg.sender] = p;
    }

    function releaseItem(uint gameId, uint itemId, uint price, bool repeatable) public {
        require(publishers[msg.sender].regeisted && publishers[msg.sender].authority);

        Item memory newItem = Item(gameId, itemId, price, 0, 0, repeatable, true);

        items.push(newItem);

        Publisher storage p = publishers[msg.sender];

        p.relesedItems[p.releasdCount++] = newItem;
    }

    function deleteItem(uint itemId) public {
        require(itemId >= 0 && msg.sender == administrator);
        items[itemId].tradeable = false;
    }


    function regeisterUser() public {
        require(msg.sender != administrator && users[msg.sender].regeisted && publishers[msg.sender].regeisted);

        User memory u;
        u.money = 0;
        u.regeisted = true;
        u.authority = true;

        users[msg.sender] = u;
    }

    function addMoney (uint8 count) public {
        require(msg.sender != administrator && users[msg.sender].regeisted);
        users[msg.sender].money += count;
    }

    function buyItem(uint itemId) public {

        User storage user = users[msg.sender];
        Item storage item = items[itemId];
        require(user.regeisted && item.itemId > 0 && item.tradeable
                && user.money >= item.price && user.authority 
                && (item.repeatable == true || user.items[item.itemId] == 0 ));

        user.items[item.itemId]++;
        user.money -= item.price;
        item.selledCount++;
    }

    function tradeItem(uint itemId, address sellerAddress, uint tradePrice) public {
        User storage buyer = users[msg.sender];
        User storage seller = users[sellerAddress];
        Item storage item = items[itemId];

        require(buyer.regeisted && item.itemId > 0 && seller.regeisted && item.tradeable && tradePrice >= 0
                && buyer.money >= item.price && buyer.authority 
                && (item.repeatable == true || buyer.items[itemId] == 0)
                && seller.items[item.itemId] != 0 && seller.authority);

        buyer.items[item.itemId]++;
        buyer.money -= tradePrice;

        seller.items[item.itemId]--;
        seller.money += tradePrice;

        item.tradeCount++;
    }

    function banUser(address userAddress) public {
        require(msg.sender == administrator);
        users[userAddress].authority = false;
    }

    function unbanUser(address userAddress) public {
        require(msg.sender == administrator);
        users[userAddress].authority = true;
    }

    function banPublisher(address publisherAddress) public {
        require(msg.sender == administrator);
        publishers[publisherAddress].authority = false;
    }

    function unbanPublisher(address publisherAddress) public {
        require(msg.sender == administrator);
        publishers[publisherAddress].authority = true;
    }
}
