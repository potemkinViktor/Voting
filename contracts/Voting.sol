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
