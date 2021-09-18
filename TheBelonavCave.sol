pragma solidity ^0.8.7;

import "./RarityInterface.sol";

interface RarityRockInterface {
    function mint(uint summonerId, uint amount) external;
}

interface AttributesInterface {
    function ability_scores(uint) external view returns (uint32,uint32,uint32,uint32,uint32,uint32);
}

contract TheBelonavCave {
    uint constant ONE_HOUR = 1 hours;
    
    RarityRockInterface private rarityRock;
    RarityInterface private rarity;
    AttributesInterface private attributes;
    
    mapping(uint => uint) public visitorLog;
    mapping(uint => uint) public visitorCount;
    
    constructor(address _rarityRock, address _rarity, address _attributes) {
        rarityRock = RarityRockInterface(_rarityRock);
        rarity = RarityInterface(_rarity);
        attributes = AttributesInterface(_attributes);
    }
    
    function prospect(uint summonerId) external view returns (uint amount) {
        (uint32 strength,,,,,) = attributes.ability_scores(summonerId);
        uint result = 2000000;
        for (uint i = 0; i < strength; i++) {
            result += ((result / 100) * 8);
        }
        return result / 1000000;
    }
    
    function collect(uint summonerId) external returns (uint rarocksMined) {
        require(block.timestamp > visitorLog[summonerId]);
        require(_isApprovedOrOwner(summonerId));
        visitorLog[summonerId] = block.timestamp + ONE_HOUR;
        visitorCount[summonerId] += 1;
        uint amount = this.prospect(summonerId);
        if (amount <= 0) {
            return 0;
        }
        rarityRock.mint(summonerId, amount);
        return amount;
    }
    
    function _isApprovedOrOwner(uint summonerId) internal view returns (bool) {
        return rarity.getApproved(summonerId) == msg.sender || rarity.ownerOf(summonerId) == msg.sender;
    }
}
