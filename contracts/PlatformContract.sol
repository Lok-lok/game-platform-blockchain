pragma solidity >=0.4.22 <0.6.0;

contract PlatformContract {

    enum EntityType {
        Administrator,
        Publisher,
        User,
        UnregisteredEntity
    }

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

        mapping(uint => uint) offers;
        uint offerCount;
    }

    /*  Item released by publisher, can be selled by publisher or traded between user
     *  itmeId: Id of its self (increasing when releasing new item, start from 1 !!!)
     *  price:  price of item setted by publisher or administrator
     *  selledCount: recorded how many this items has been selled by publisher
     *  tradeCount: recorded how many this items has been traded between user
     *  repeatable: whether this item can be owned by user more than once (such as all game is unrepeatable)
     *  tradeable:  whether this item can be traded (both between publisher and user / user and user)
     */
    struct Item {
        address publisherAdress;
        uint typeId;
        uint itemId; 
        uint price;
        uint selledCount;
        uint tradeCount;
        bool repeatable;
        bool tradeable;
    }

    /*  Publisher who can publish game or related Items
     *  releasedItem: item published by this publisher
     *  authority: whether this publisher can publish game in the future
     *  regeisted: this publisher has been regeisted or not
     *  releasedCount: number of items released by this publisher
     */
    struct Publisher {
        mapping(uint => Item) releasedItems; 
        bool authority;
        bool regeisted;
        bool exists;
        uint releasedCount;
    }
    
    struct Offer {
        address sellerAdress;
        uint itemId;
        uint price;
        bool active;
    }

    address public administrator;
    mapping(address => User) public users; 
    mapping(address => Publisher) public publishers;
    mapping(uint => Item) public items;
    mapping(uint => Offer) public offers;
    uint globalOfferId; // start from 1/ 0 means null
    uint public globalItemId; // start from 1/ 0 means null

    constructor() public {
        administrator = msg.sender;
        globalOfferId = 1;
        globalItemId = 1;
    }

    function registerPublisher() public {
        require(msg.sender != administrator && !users[msg.sender].regeisted && !publishers[msg.sender].regeisted);

        Publisher memory p;
        p.authority = true;
        p.regeisted = true;

        publishers[msg.sender] = p;
    }

    function releaseItem(uint typeId, uint itemId, uint price, bool repeatable) public {
        require(publishers[msg.sender].regeisted && publishers[msg.sender].authority
                 && price >= 0 && itemId > 0);

        Item memory newItem = Item(msg.sender, typeId, itemId, price, 0, 0, repeatable, true);
        items[globalItemId++] = newItem;

        Publisher storage p = publishers[msg.sender];
        p.releasedItems[p.releasedCount++] = newItem;
    }

    function deleteItem(uint itemId) public {
        require(itemId > 0 && msg.sender == administrator);
        items[itemId].tradeable = false;
    }

    function registerUser() public {
        require(msg.sender != administrator && !users[msg.sender].regeisted && !publishers[msg.sender].regeisted);

        User memory u;
        u.money = 0;
        u.offerCount = 0;
        u.regeisted = true;
        u.authority = true;

        users[msg.sender] = u;
    }

    function addMoney (uint count) public {
        require(msg.sender != administrator && users[msg.sender].regeisted);
        users[msg.sender].money += count;
    }

    function buyItem(uint itemId) public {

        User storage user = users[msg.sender];
        Item storage item = items[itemId];
        require(user.regeisted && itemId > 0 && item.tradeable
                && user.money >= item.price && user.authority 
                && (item.repeatable == true || user.items[itemId] == 0));

        user.items[itemId]++;
        user.money -= item.price;
        item.selledCount++;
    }
    
    function makeOffer(uint itemId, uint tradePrice) public {
        User storage seller = users[msg.sender];
        Item storage item = items[itemId];
        
        require(itemId > 0 && seller.regeisted && item.tradeable
            && seller.items[itemId] > 0 && seller.authority);
            
        Offer memory offer;
        offer.sellerAdress = msg.sender;
        offer.itemId = itemId;
        offer.price = tradePrice;
        offer.active = true;

        offers[globalOfferId] = offer;
        seller.offers[seller.offerCount++] = globalOfferId;

        seller.items[itemId]--;
        globalOfferId++;
    }

    function recallOffer(uint offerId) public {
        require(offerId > 0 && offers[offerId].sellerAdress == msg.sender 
                && users[msg.sender].regeisted && offers[offerId].active);
        users[msg.sender].items[offers[offerId].itemId]++;
        offers[offerId].active = false;
    }


    function tradeItem(uint offerId) public {
        User storage buyer = users[msg.sender];
        User storage seller = users[offers[offerId].sellerAdress];
        uint itemId = offers[offerId].itemId;
        Item storage item = items[itemId];
        uint tradePrice = offers[offerId].price;

        require(buyer.regeisted && itemId > 0 && seller.regeisted && item.tradeable && offers[offerId].active
                && buyer.money >= item.price && buyer.authority 
                && (item.repeatable == true || buyer.items[itemId] == 0)
                && seller.items[itemId] != 0 && seller.authority);

        // mapping generates default value
        buyer.items[itemId]++;
        buyer.money -= tradePrice;

        seller.items[itemId]--;
        seller.money += tradePrice;
        if (seller.items[itemId] <= 0) {
            delete seller.items[itemId];
        }

        item.tradeCount++;
        offers[offerId].active = false;
    }

    function banUser(address userAddress) public {
        require(msg.sender == administrator);
        users[userAddress].authority = false;
        // TODO: revoke all the offers posted
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

    function getTradeCount(uint itemId) public view returns (uint) {
        require(msg.sender == items[itemId].publisherAdress);
        return items[itemId].tradeCount;
    }

    function getSelledCount(uint itemId) public view returns (uint) {
        require(msg.sender == items[itemId].publisherAdress);
        return items[itemId].selledCount;
    }

    function getReleasedCount() public view returns (uint) {
        return publishers[msg.sender].releasedCount;
    }
    
    function getReleasedItemId(uint i) public view returns (uint) {
        return publishers[msg.sender].releasedItems[i].itemId;
    }

    function getTypeId(uint itemId) public view returns (uint) {
        return items[itemId].typeId;
    }

    function getPrice(uint itemId) public view returns (uint) {
        return items[itemId].price;
    }

    function userType() public view returns (EntityType) {
        if (msg.sender == administrator) {
            return EntityType.Administrator;
        }
        if (publishers[msg.sender].regeisted) {
            return EntityType.Publisher;
        }
        if (users[msg.sender].regeisted) {
            return EntityType.User;
        }
        return EntityType.UnregisteredEntity;
    }
}
