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
        mapping(uint8 => uint8) items; 
        uint8 money;
        bool authority;
        bool regeisted;

        mapping(uint8 => uint8) offers;
        uint8 offerCount;
    }

    /*  Item released by publisher, can be selled by publisher or traded between user
     *  itmeId: Id of its self (increasing when releasing new item, start from 1 !!!)
     *  price:  price of item setted by publisher or administrator
     *  sellCount: recorded how many this items has been selled by publisher
     *  tradeCount: recorded how many this items has been traded between user
     *  repeatable: whether this item can be owned by user more than once (such as all game is unrepeatable)
     *  tradeable:  whether this item can be traded (both between publisher and user / user and user)
     *  name: Name of this item
     *  allowQuery: whether its publisher can get its traded count and selled count
     */
    struct Item {
        address publisherAdress;
        uint8 typeId;
        uint8 itemId; 
        uint8 price;
        uint8 sellCount;
        uint8 tradeCount;
        bool repeatable;
        bool tradeable;

        string itemName;
        bool allowQuery;
    }

    /*  Publisher who can publish game or related Items
     *  releasedItem: item published by this publisher
     *  authority: whether this publisher can publish game in the future
     *  regeisted: this publisher has been regeisted or not
     *  releasedCount: number of items released by this publisher
     */
    struct Publisher {
        mapping(uint8 => Item) releasedItems; 
        bool authority;
        bool regeisted;
        bool exists;
        uint8 releasedCount;
    }
    
    struct Offer {
        address sellerAdress;
        uint8 itemId;
        uint8 price;
        bool active;
    }

    address public administrator;
    mapping(address => User) public users;
    mapping(address => Publisher) public publishers;
    mapping(uint8 => Item) public items;
    mapping(uint8 => Offer) public offers;
    uint8 public globalOfferId; // id prepared for next item / start from 1 and 0 means null
    uint8 public globalItemId; // id prepared for next offer / start from 1 and 0 means null

    address[] private userList;
    address[] private publisherList;

    constructor() public {
        administrator = msg.sender;
        globalOfferId = 1;
        globalItemId = 1;
    }

    // regeisting function
    function registerPublisher() public {
        require(isNobody(msg.sender));
        Publisher memory p;
        p.authority = true;
        p.regeisted = true;

        publishers[msg.sender] = p;
        publisherList.push(msg.sender);
    }

    function registerUser() public {
        require(isNobody(msg.sender));
        User memory u;
        u.money = 0;
        u.offerCount = 0;
        u.regeisted = true;
        u.authority = true;

        users[msg.sender] = u;
        userList.push(msg.sender);
    }

    // function for user

    function addMoney (uint8 count) public {
        //require(isUser(msg.sender));
        users[msg.sender].money += count;
    }

    function buyItem(uint8 itemId) public {

        //require(isUser(msg.sender) && isValidItemId(itemId));

        User storage user = users[msg.sender];
        Item storage item = items[itemId];
        require(item.tradeable
                && user.money >= item.price && user.authority 
                && (item.repeatable == true || user.items[itemId] == 0));

        user.items[itemId]++;
        user.money -= item.price;
        item.sellCount++;
    }
    
    function makeOffer(uint8 itemId, uint8 tradePrice) public {
        //require(isUser(msg.sender) && isValidItemId(itemId));
        User storage seller = users[msg.sender];
        Item storage item = items[itemId];
        
        require(seller.regeisted && item.tradeable
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

    function recallOffer(uint8 offerId) public {
        //require(isUser(msg.sender));
        require(offerId > 0 && offers[offerId].sellerAdress == msg.sender && offers[offerId].active);
        users[msg.sender].items[offers[offerId].itemId]++;
        offers[offerId].active = false;
        users[msg.sender].money += offers[offerId].price;
    }


    function tradeItem(uint8 offerId) public {

        address sellerAdress = offers[offerId].sellerAdress;
        //require(isUser(msg.sender) && isUser(sellerAdress));

        User storage buyer = users[msg.sender];
        User storage seller = users[sellerAdress];
        uint8 itemId = offers[offerId].itemId;
        Item storage item = items[itemId];
        uint8 tradePrice = offers[offerId].price;

        require(isValidItemId(itemId) && item.tradeable && offers[offerId].active
                && buyer.money >= tradePrice && buyer.authority 
                && (item.repeatable == true || buyer.items[itemId] == 0)
                && seller.authority);

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

    function getUserItem(uint8 itemId) public view returns (uint8) {
        //require(isUser(msg.sender) && isValidItemId(itemId));
        return users[msg.sender].items[itemId];
    }

    function getMoney() public view returns (uint8) {
        //require(isUser(msg.sender) && isValidItemId(itemId));
        return users[msg.sender].money;
    }

    function getOfferActivity(uint8 offerId) public view returns (bool) {
        //require(isUser(msg.sender) && isValidItemId(itemId));
        return offers[offerId].active;
    }

    function getOfferItemId(uint8 offerId) public view returns (uint8) {
        //require(isUser(msg.sender) && isValidItemId(itemId));
        return offers[offerId].itemId;
    }

    function getOfferPrice(uint8 offerId) public view returns (uint8) {
        //require(isUser(msg.sender) && isValidItemId(itemId));
        return offers[offerId].price;
    }

    function getSellerAdress(uint8 offerId) public view returns (address) {
        //require(isUser(msg.sender) && isValidItemId(itemId));
        return offers[offerId].sellerAdress;
    }


    
    // function for publisher
    function releaseItem(uint8 typeId, uint8 itemId, uint8 price, bool repeatable, string memory itemName) public {
        //require(isPublisher(msg.sender));
        require(publishers[msg.sender].authority && price >= 0);

        Item memory newItem = Item(msg.sender, typeId, itemId, price, 0, 0, repeatable, true, itemName, false);
        items[globalItemId++] = newItem;

        Publisher storage p = publishers[msg.sender];
        p.releasedItems[p.releasedCount++] = newItem;
    }

    function getReleasedCount() public view returns (uint8) {
        require(isPublisher(msg.sender));
        return publishers[msg.sender].releasedCount;
    }
    
    function getReleasedItemId(uint8 i) public view returns (uint8) {
        require(isPublisher(msg.sender));
        require(i >= 0 && i < publishers[msg.sender].releasedCount);
        return publishers[msg.sender].releasedItems[i].itemId;
    }

    function allowQuery(uint8 itemId) public {
        require( isPublisher(msg.sender) && msg.sender == items[itemId].publisherAdress && isValidItemId(itemId));
        items[itemId].allowQuery = true;
    }


    function getAllowQuery(uint8 itemId) public view returns (bool){
        require( isPublisher(msg.sender) && msg.sender == items[itemId].publisherAdress && isValidItemId(itemId));
        return items[itemId].allowQuery;
    }

    function getTradeCount(uint8 itemId) public view returns (uint8) {
        require( isPublisher(msg.sender) && msg.sender == items[itemId].publisherAdress 
                && isValidItemId(itemId) && items[itemId].allowQuery);
        return items[itemId].tradeCount;
    }

    function getSellCount(uint8 itemId) public view returns (uint8) {
        require( isPublisher(msg.sender) && msg.sender == items[itemId].publisherAdress 
                && isValidItemId(itemId) && items[itemId].allowQuery);
        return items[itemId].sellCount;
    }

    // function provided for administrator
    function banUser(address userAddress) public {
        require(isAdministrator(msg.sender) && isUser(userAddress));
        users[userAddress].authority = false;
        // TODO: revoke all the offers posted 
        // Wei: just hide it on js layer?
    }

    function unbanUser(address userAddress) public {
        require(isAdministrator(msg.sender) && isUser(userAddress));
        users[userAddress].authority = true;
    }

    function deleteItem(uint8 itemId) public {
        require(isAdministrator(msg.sender) && isValidItemId(itemId));
        items[itemId].tradeable = false;
    }

    function banPublisher(address publisherAddress) public {
        require(isAdministrator(msg.sender) && isPublisher(publisherAddress));
        publishers[publisherAddress].authority = false;
    }

    function unbanPublisher(address publisherAddress) public {
        require(isAdministrator(msg.sender) && isPublisher(publisherAddress));
        publishers[publisherAddress].authority = true;
    }

    function banQuery(uint8 itemId) public {
        require(isAdministrator(msg.sender) && isValidItemId(itemId));
        items[itemId].allowQuery = false;
    }

    // helper function for checking

    function isPublisher (address targetAddress) public view returns (bool) {
        return targetAddress != administrator && !users[targetAddress].regeisted && publishers[targetAddress].regeisted;
    }

    function isAdministrator(address targetAddress) public view returns (bool) {
        return targetAddress == administrator && !users[targetAddress].regeisted && !publishers[targetAddress].regeisted;
    }

    function isUser(address targetAddress) public view returns (bool) {
        return targetAddress != administrator && users[targetAddress].regeisted && !publishers[targetAddress].regeisted;
    }

    function isNobody(address targetAddress) public view returns (bool) {
       return targetAddress != administrator && !users[targetAddress].regeisted && !publishers[targetAddress].regeisted;
    }

    function isValidItemId(uint8 itemId) public view returns (bool) {
        return itemId > 0 && itemId < globalItemId;
    }


    // basic get function

    function getTypeId(uint8 itemId) public view returns (uint8) {
        require(isValidItemId(itemId));
        return items[itemId].typeId;
    }

    function getPrice(uint8 itemId) public view returns (uint8) {
        require(isValidItemId(itemId));
        return items[itemId].price;
    }

    function getItemName(uint8 itemId) public view returns (string memory) {
        return items[itemId].itemName;
    }

    function getUserList() public view returns (address[] memory) {
        require(msg.sender == administrator);
        return userList;
    }
    
    function getPublisherList() public view returns (address[] memory) {
        require(msg.sender == administrator);
        return publisherList;
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
