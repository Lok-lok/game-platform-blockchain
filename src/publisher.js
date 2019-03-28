ID2TypeName = {
    0 : "GAME",
    1 : "SKIN",
    2 : "CG"
  },


App = {
  loading: false,
  contracts: {},
  itemToShowTradeCount: 0,

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

    const releasedCount = await App.Platform.getReleasedCount()
    for (var i = 0; i < releasedCount; i++) {
      var itemId = (await App.Platform.getReleasedItemId(i)).toNumber();
      var itemType =  (await App.Platform.getTypeId(itemId)).toNumber();
      var itemPrice = (await App.Platform.getPrice(itemId)).toNumber();
      var itemName = await App.Platform.getName(itemId);

      $("#ReleasedItems").append("<tr><th>" + itemName + "</th><td>" + ID2TypeName[itemType] + "</td><td>"
                                + itemPrice + " $"+ "</td><tr>" )
    }
  },
  
  publisherRelease: async () => {

    var itemId = (await App.Platform.globalItemId()).toNumber();
    var itemName = $('#itemName').val();
    var itemType = $('#itemType').val();
    var itemPrice = parseInt($('#itemPrice').val());
    var repeatable = $('#itemRepeatable').val();

    await App.Platform.releaseItem(itemType, itemId, itemPrice, !!repeatable, itemName);
    window.location.reload()

  },

  // publisherQueryTradeCount: async () => {
  // },
  
  // publisherQueryselledCount: async () => {
  // },

  
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