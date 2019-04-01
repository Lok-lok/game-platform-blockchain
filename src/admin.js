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
    App.renderUserList()
    App.renderPublisherList()
    
    App.setLoading(false)
  },
  
  renderUserList: async () => {
    let userList = await App.Platform.getUserList()
    for (var i = 0; i < userList.length; i++) {
      let address = userList[i]
      let user = await App.Platform.users(address)
      let money = user[0].c[0]
      let authority = user[1]
      string = "<tr><th>" + address + "</th>"
      string += "<td>" + money + "</td>"
      string += "<td>" + authority + "</td></tr>"
      $("#user-list").append(string)
    }
  },
  
  renderPublisherList: async () => {
    let publisherList = await App.Platform.getPublisherList()
    for (var i = 0; i < publisherList.length; i++) {
      let address = publisherList[i]
      let publisher = await App.Platform.publishers(address)
      let releasedCount = publisher[3].c[0]
      let authority = publisher[0]
      string = "<tr><th>" + address + "</th>"
      string += "<td>" + releasedCount + "</td>"
      string += "<td>" + authority + "</td></tr>"
      $("#publisher-list").append(string)
    }
  },
  
  
  banUser: async () => {
    App.setLoading(true)
    var string = $('#banUserId').val();
    await App.Platform.banUser(string)
    window.location.reload()
  },

  unbanUser: async () => {
    App.setLoading(true)
    var string = $('#unbanUserId').val();
    await App.Platform.unbanUser(string)
    window.location.reload()
  },

  banPublisher: async () => {
    App.setLoading(true)
    var string = $('#banPublisherId').val();
    await App.Platform.banPublisher(string)
    window.location.reload()
  },

  unbanPublisher: async (string) => {
    App.setLoading(true)
    var string = $('#unbanPublisherId').val();
    await App.Platform.unbanPublisher(string)
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