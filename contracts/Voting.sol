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