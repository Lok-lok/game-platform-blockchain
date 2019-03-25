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

    // Render Account
    $('#accountAddress').html(App.account)
    await App.renderItems()
    await App.renderTradeCount()
    await App.renderselledCount()

    App.setLoading(false)
  },

  renderItems: async () => {
    const releasedCount = await App.Platform.getReleasedCount()
    for (var i = 0; i < releasedCount; i++) {
      const itemId = await App.Platform.getReleasedItemId(i)
      const type =  await App.Platform.items(i).type()
      $("#ReleasedItems").append("<tr><th>" + id2Name(itemId) + "</th><td>" + type + "</td></tr>")
    }
  },
  
  renderTradeCount(): async () => {
  },

  renderselledCount(): async () => {
  },

  publisherRelease: async () => {
  },

  publisherQueryTradeCount: async () => {
  },
  
  publisherQueryselledCount: async () => {
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