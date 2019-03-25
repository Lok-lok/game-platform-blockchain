var userTypeHTML = {
  0 : "admin.html",
  1 : "publisher.html",
  2 : "user.html",
  3 : "unregistered.html"
},
  
App = {
  
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
    await App.render()
    await App.redirect()
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
    App.divRedirect = $("#redirect")
    App.divLoad = $("#load")
    
    App.setLoading(true)
    
    // Render Account
    $('#accountAddress').html(App.account)
    
    App.setLoading(false)
  },

  userType: async () => {
    var type = await App.Platform.userType()
    return type.c[0]
  },
  
  redirect: async() => {
    var type = await App.userType()
    window.location.href = userTypeHTML[type]
  },
  
  setLoading: async (boolean) => {
    if (boolean) {
      App.divRedirect.hide()
      App.divLoad.show()
    } else {
      App.divRedirect.show()
      App.divLoad.hide()
    }
  },
}

$(() => {
  $(window).load(() => {
    App.load()
  })
})