ID2TypeName = {

  0 : "GAME",

  1 : "SKIN",

  2 : "CG"

},

App = {
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
    await App.render()
  },

  loadWeb3: async () => {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider
      web3 = new Web3(web3.currentProvider)
    } else {
      window.alert("Please connect to Metamask.")
    }
    // Modern dapp browsers...
    if (window.ethereum) {
      window.web3 = new Web3(ethereum)
      try {
        // Request account access if needed
        await ethereum.enable()
        // Acccounts now exposed
        web3.eth.sendTransaction({/* ... */})
      } catch (error) {
        // User denied account access...
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = web3.currentProvider
      window.web3 = new Web3(web3.currentProvider)
      // Acccounts always exposed
      web3.eth.sendTransaction({/* ... */})
    }
    // Non-dapp browsers...
    else {
      console.log('Non-Ethereum browser detected.')
    }
  },

  loadAccount: async () => {
    // Set the current blockchain account
    App.account = web3.eth.accounts[0]
  },

  loadContract: async () => {
    // Create a JavaScript version of the smart contract
    const  PlatformContract = await $.getJSON('PlatformContract.json')
    App.contracts.Platform = TruffleContract(PlatformContract)
    App.contracts.Platform.setProvider(App.web3Provider)



    // Hydrate the smart contract with values from the blockchain
    App.Platform = await App.contracts.Platform.deployed()
  },


  render: async () => {
    App.loader = $("#loader");
    App.content = $("#content");
    App.setLoading(true)

    $('#accountAddress').html(App.account)
    await App.renderItems()

    App.setLoading(false)
  },
  renderItems: async () => {

    const itemCounts = (await App.Platform.globalItemId()).toNumber();
    for (var i = 1; i < itemCounts; i++) {
      var itemId = i;
      var itemType =  (await App.Platform.getTypeId(itemId)).toNumber();
      var itemPrice = (await App.Platform.getPrice(itemId)).toNumber();
      var itemName = await App.Platform.getItemName(itemId);


      $("#ReleasedItems ").append("<tr><th>" + itemId + "</th><td>" +"N/A"+"</td><td>"+ itemName + "</td><td>" + (itemPrice + " $") + "</td><td>"

          + ID2TypeName[itemType] + "</td><td>" +"Publisher"+ "</td><tr>" );

    }
    const itemPostedCount = (await App.Platform.globalOfferId()).toNumber();

    for (var i = 1; i < itemPostedCount; i++) {

      if(await App.Platform.getOfferActivity(i)) {
        var itemId = (await App.Platform.getOfferItemId(i)).toNumber();
        var itemType = (await App.Platform.getTypeId(itemId)).toNumber();
        var itemPrice = (await App.Platform.getOfferPrice(i)).toNumber();
        var itemName = await App.Platform.getOfferName(i);
        var itemSeller = (await App.Platform.getOfferSellerId(i));

        $("#ReleasedItems").append("<tr><th>" + itemId + "</th><td>" + i + "</td><td>" + itemName + "</td><td>" + ("$" + itemPrice) + "</td><td>" + ID2TypeName[itemType] + "</td><td>"

            + itemSeller + "</td><tr>");
      }
    }

    const userItemCount = (await App.Platform.globalItemId()).toNumber();


    for (var i = 0; i < userItemCount; i++) {
      var amount = (await (App.Platform.getUserItem(i)));

      if(amount>0) {
         var itemId = i;
         var itemType = (await App.Platform.getTypeId(itemId)).toNumber();
         var itemName = await App.Platform.getItemName(i);

        $("#OwnedItems").append("<tr><th>" + itemId + "</th><td>" + itemName + "</td><td>" + ID2TypeName[itemType] +"</td><td>" +amount+ "</td><tr>");
      }


    }

    $("#currentMoney").append("Balance: $"+(await App.Platform.getMoney()).toNumber());
  },


  userRegeister: async () => {
  },

  userRecallOffer: async () => {
    var offerId = $('#offerIdRecall').val();
    await App.Platform.recallOffer(offerId);
    window.location.reload()

  },
  userAddMoney: async () => {
    var amount = $('#money').val();
    await App.Platform.addMoney(amount);
    window.location.reload();
  },

  userPostOffer: async () => {
    var itemId = $('#itemId').val();
    var itemPrice = parseInt($('#itemPrice').val());
    await App.Platform.makeOffer(itemId, itemPrice);
    window.location.reload()
  },

  userBuy: async () => {
    var item = $('#publisherBuy').val();
    await App.Platform.buyItem(item);
    window.location.reload()
  },

  userTrade: async () => {
    var offerId = $('#offerIdTrade').val();
    await App.Platform.tradeItem(offerId);
    window.location.reload()

  },


  setLoading: async (boolean) => {
    if (boolean) {
      App.loader.show();
      App.content.hide();
    } else {
      App.loader.hide();
      App.content.show();
    }
  },
}

$(() => {
  $(window).load(() => {
    App.load()
  })
})