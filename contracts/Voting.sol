<<<<<<< HEAD
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    struct Voter{
        bool voted;
        uint256 voteFor;
    }

    struct Candidate {
        address name;
        uint256 votes;
    }

    uint256 timeDeploy;
    bool votingIsOver;
    bool moneyTransfered;

    mapping(address => Voter) public voters;

    Candidate[] public candidates;

    constructor() {
        timeDeploy = block.timestamp;
    }

    function addCandidate(address[] memory _candidates) public onlyOwner {
        for (uint256 i = 0; i < _candidates.length; i++) {
            candidates.push(Candidate({
                name: _candidates[i],
                votes: 0
            }));
        }
    }

    function voting(uint256 _voteFor) public payable {
        require(block.timestamp < 3 days + timeDeploy, "The voting is over");
        require(msg.value == 0.01 ether, "You should donate 0.01 ETH");
        require(_voteFor <= candidates.length, "You should choose candidate from list");
        require(!voters[msg.sender].voted, "You already have a vote");
        voters[msg.sender].voted = true;
        voters[msg.sender].voteFor = _voteFor;
        candidates[_voteFor].votes += 1;
    }

    function getWinner() public payable{
        require(votingIsOver, "The voting is not over");
        uint256 maxSupply;
        uint256 winner;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].votes > maxSupply)
                maxSupply = candidates[i].votes;
                winner = 1;
        }
        moneyTransfered = true;
        payable(candidates[winner].name).transfer(address(this).balance * 90 / 100);
    }

    function endVoting() public {
        require(block.timestamp >= 3 days + timeDeploy, "The voting is not over");
        votingIsOver = true;
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(moneyTransfered, "Money not transfered to the winner");
        require(_to != address(0), "Wrong address");
        require(votingIsOver, "The voting is not over");
        require(_amount <= address(this).balance, "Not enough money to transfer");
        payable(_to).transfer(_amount);
    }
}
=======
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    struct Candidate {
        address canidateAddress;
        uint256 voteCount;
    }

    struct Voters {
        bool voted;
        uint256 vote;
    }

    uint256 private totalVotes = 0; //для безопасности, сравнить сколько проголосовало и  сколько могло проголосовать

    mapping(address => Voters) public voters;

    Candidate[] public candidates;

    event Votes(address _from, address _to);
    event Winner(address _winner, uint256 _moneyTransfered);
    event Withdraw(address _to, uint256 _amount);

    function poll() public view onlyOwner returns(uint256) {
        return block.timestamp;
    }

    function addVoter(address _canidateAddress) public onlyOwner {
        require(_canidateAddress != address(0), "Wrong address");
        candidates.push(Candidate(_canidateAddress, 0));
    }

    function getNumCandidates() public view returns(uint256) {
        return candidates.length;
    }

    function voting(uint256 _amount, uint256 _voteID) public payable{
        require(block.timestamp < 3 days + poll(), "Voting is over");
        require(!voters[msg.sender].voted, "You alredy vote in this poll");//задать voted false изначально
        require(_amount == .01 ether, "You need to send 0.01 ETH for voting");
        voters[msg.sender].vote = _voteID;
        voters[msg.sender].voted = true;
        candidates[_voteID].voteCount += 1;
        totalVotes += 1;//этот счетчик бесполезен, я его использую только для вывода для Winner, мб его удалить новую реализацию??
        emit Votes(msg.sender, candidates[_voteID].canidateAddress);
    }

    function getWinner() public payable {
        require(block.timestamp >= 3 days + poll(), "");
        uint256 _maxVoteCount = 0;
        uint256 _winnerID;
        for (uint256 i=1; i <= getNumCandidates(); i++) {
            if (candidates[i].voteCount > _maxVoteCount) {
                _maxVoteCount = candidates[i].voteCount;
                _winnerID = i;
            }
        payable(candidates[_winnerID].canidateAddress).transfer(totalVotes * 90 /1000); //вывести 90 процентов денег с контракта целесообразно ли использовать именно такой способ?
        // очистить mapping and struct для возможности создания нового голосования или это не нужно по тз?
        emit Winner(candidates[_winnerID].canidateAddress, totalVotes * 90 /1000);
        }
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_to != address(0), "Wrong address");
        payable(_to).transfer(_amount);
        emit Withdraw(_to, _amount);
    }
}
>>>>>>> 5e936517505edafbbf5fac3e009ff9c9aac90c29
