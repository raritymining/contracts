pragma solidity ^0.8.7;

interface RarityInterface {
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
}
