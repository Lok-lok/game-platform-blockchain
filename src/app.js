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

    await App.renderVoteResult()
    await App.renderVote()
    await App.renderOpen()
    await App.renderHistory()
    
    App.setLoading(false)
  },

  renderVoteResult: async () => {
    const proposalCount = await App.voting.proposalCount()
    const winner = await App.voting.getWin()
    for (var i = 0; i < proposalCount; i++) {
      const proposal = await App.voting.proposals(i)
      $("#candidatesResults").append("<tr><th>" + i + "</th><td>" + proposal + "</td></tr>")
    }
    
    if (winner.length != proposalCount) {
      string = "Winner(s):"
      for (var i = 0; i < winner.length; i++)
        string += " " + winner[i].c[0]
      $('#winner').html(string)
    } else {
      $('#winner').html("No winner determined previously")
    }
  },
  
  renderVote: async () => {
    const openToVote = await App.voting.openToVote()
    const proposalCount = await App.voting.proposalCount()
    const vote_ret = await App.voting.getVote()
    const vote = vote_ret.c[0]
    const normal = vote_ret.s == 1
    
    const voter_div = $('#voter')
    const vote_div = $('#vote')
    const unvote_div = $('#unvote')
    
    if (openToVote) {
      if (vote >= proposalCount) {
        for (var i = 0; i < proposalCount; i++) {
          $('#candidatesSelect').append("<option value='" + i + "' >" + i + "</ option>")
        }
        vote_div.show()
        unvote_div.hide()
      } else {
        const status = $('#normal_ban')
        $('#voteFor').html("Voted for: " + vote)
        if (normal) {
          status.html("Status: Normal")
        } else {
          status.html("Status: Banned")
        }
        vote_div.hide()
        unvote_div.show()
      }
    } else {
      voter_div.hide()
    }
  },

  renderOpen: async () => {
    const openToVote = await App.voting.openToVote()
    
    const startVoting_div = $('#startVoting')
    const endVoting_div = $('#endVoting')
    const chairperson_div = $('#chairperson')
    const status = $('#status')
    if (openToVote) {
      status.html("OPEN")
    } else {
      status.html("CLOSED")
    }
    App.voting.chairperson().then(function(chairperson) {
      if (App.account == chairperson) {
        if (openToVote) {
          startVoting_div.hide()
          endVoting_div.show()
        } else {
          startVoting_div.show()
          endVoting_div.hide()
        }
        chairperson_div.show()
      } else {
        chairperson_div.hide()
      }
    })
  },
  
  renderHistory: async () => {
    let logVote = App.voting.LogVote({}, {fromBlock: 0, toBlock: 'latest'})
    logVote.get((error, logs) => {
      // we have the logs, now print them
      logs.forEach(log => {
        let vote = log.args["vote"].s == 1
        string = "<tr><th>" + log.args["vote"].c[0] + "</th><td>"
        if (vote) {
          string += "Vote"
        } else {
          string += "Unvote"
        }
        string += "</td><td>" + log.args["voter"] + "</td><td>" +  log.args["timestamp"].c[0] + "</td></tr>"
        $("#history").append(string)
      })
    })
  },

  userRegeister: async () => {
  },

  userRecharge: async () => {
  },

  userPostOffer: async () => {
  },

  userBuy: async () => {
  },

  userTrade: async () => {
  },


  publiserRegeister: async () => {
  },

  publiserRelease: async () => {
  },

  publiserQueryTradeCount: async () => {
  },
  
  publiserQueryselledCount: async () => {
  },
  
  banUser: async () => {
  },

  unBanUser: async () => {
  },

  banPublisher: async () => {
  },

  unBanPublisher: async () => {
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