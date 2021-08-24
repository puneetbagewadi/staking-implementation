// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract StakingContract is Ownable {
    using SafeMath for uint256;

    address[] internal allStakers;
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;

 
    constructor(address _owner, uint256 _supply) { 
        super();
    }


    function stakeToken(uint256 _stake) public {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }

    function unstakeToken(uint256 _stake)
        public
    {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        _mint(msg.sender, _stake);
    }

    // ---------- allStakers ----------

    function addStaker(address _stakeholder) public {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) allStakers.push(_stakeholder);
    }


    function removeStaker(address _stakeholder) public {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            allStakers[s] = allStakers[allStakers.length - 1];
            allStakers.pop();
        } 
    }

   
    function calculateReward(address _stakeholder) public view returns(uint256) {
        return stakes[_stakeholder] / 100;
    }

    function distributeRewards() public onlyOwner
    {
        for (uint256 s = 0; s < allStakers.length; s += 1){
            address stakeholder = allStakers[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }

    function claimReward() public
    {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }
}