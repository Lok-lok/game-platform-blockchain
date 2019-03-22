pragma solidity >=0.4.22 <0.6.0;

contract VotingContract {

    struct Voter {
        bool banned;
        bool voted;
        uint8 vote;
    }
    
    struct Proposal {
        uint count;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals; // mapping is not iterable
    uint8 public proposalCount;
    bool public openToVote;
    uint8[] win;

    constructor(uint8 numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].banned = false;
        proposalCount = numProposals;
        proposals.length = numProposals;
        openToVote = false;
    }
    
    event LogVote(int16 vote, uint256 timestamp, address voter);
    
    function startVoting() public {
        openToVote = true;
    }
    
    function endVoting() public {
        openToVote = false;
    }

    function allowToVote(address voter) public {
        if (msg.sender != chairperson || !voters[voter].banned) return;
        if (voters[voter].voted) {
            proposals[voters[voter].vote].count++;
        }
        voters[voter].banned = false;
    }

    function banVote(address voter) public {
        if (msg.sender != chairperson || voters[voter].banned) return;
        if (voters[voter].voted) {
            proposals[voters[voter].vote].count--;
        }
        voters[voter].banned = true;
    }

    function unvote() public {
        Voter storage sender = voters[msg.sender];
        if (!sender.voted || !openToVote) return;
        sender.voted = false;
        emit LogVote(0 - int16(sender.vote), now, msg.sender);
        if (!sender.banned) proposals[sender.vote].count--;
    }
    
    function vote(uint8 proposal) public {
        Voter storage sender = voters[msg.sender];
        if (sender.voted || proposal >= proposals.length || !openToVote) return;
        sender.voted = true;
        sender.vote = proposal;
        emit LogVote(proposal, now, msg.sender);
        if (!sender.banned) proposals[proposal].count++;
    }
    
    function getVote() public view returns (int16) {
        Voter storage sender = voters[msg.sender];
        return sender.voted ? (sender.banned ? 0 - int16(sender.vote) : int16(sender.vote)) : int16(256); // banned: -vote, unvote: 256
    }

    function decideWin() public returns (uint8[] memory) {
        if (msg.sender != chairperson) return getWin();
        uint256 max = 0;
        for (uint8 i = 0; i < proposals.length; i++)
        {
            if (proposals[i].count > max) {
                max = proposals[i].count;
                while (win.length > 0){
                    win.pop();
                }
            }
            if (proposals[i].count == max) win.push(i);
        }
        uint8[] memory ret = new uint8[](win.length);
        for (uint8 i = 0; i < win.length; i++)
            ret[i] = win[i];
        return ret;
    }
    
    function getWin() public view returns (uint8[] memory) {
        uint8[] memory ret = new uint8[](win.length);
        for (uint8 i = 0; i < win.length; i++)
            ret[i] = win[i];
        return ret;
    }
}
