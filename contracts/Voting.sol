//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

// нельзя создавать poll когда ужее создан подумать 

contract Voting is Ownable {

    struct Voters {
        address voter;
        bool voted;
        uint256 vote;
        uint256 voteCount;
    }

    uint256 private totalVotes = 0; //для безопасности, сравнить сколько проголосовало и  сколько могло проголосовать

    mapping(address => Voters) public voters;
    //mapping(address => bool) public addressVoted;

    Voters[] public candidates;

    event Votes(address _from, address _to);
    event Winner(address _winner, uint256 _moneyAmount);
    event Withdraw(address _to, uint256 _amount);

    function poll() public view onlyOwner returns(uint256) {
        return block.timestamp;
    }

    function addVoter(address _voter) public onlyOwner {
        require(_voter != address(0), "Wrong address");
        // proverka chto poll started
        candidates.push(Voters(_voter, false, 0, 0));
    }

    function getNumCandidates() public view returns(uint256) {
        return candidates.length;
    }

    function voting(uint256 _amount, uint256 _voteID) public payable{
        require(block.timestamp < 3 days + poll(), "");
        require(!voters[msg.sender].voted, "You alredy vote in this poll");
        require(_amount == 0.01 ether, "You need to send 0.01 ETH for voting");
        voters[msg.sender].vote = _voteID;
        voters[msg.sender].voted = true;
        candidates[_voteID].voteCount += 1;
        totalVotes += 1;
    }

    function getWinner() public payable {
        require(totalVotes <= getNumCandidates(), " ");
            uint256 _maxVoteCount = 0;
            uint256 _winnerID;
            for (uint256 i=1; i <= getNumCandidates(); i++) {
                if (candidates[i].voteCount > _maxVoteCount) {
                    _maxVoteCount = candidates[i].voteCount;
                    _winnerID = i;
                }
            payable(candidates[_winnerID].voter).transfer(this.balance * 90 /10); //вывести 90 процентов денег с контракта 
            // очистить mapping
            }
    }

    function withdraw(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Wrong address");
        payable(to).transfer(amount);

        emit Withdraw(to, amount);
    }
}
