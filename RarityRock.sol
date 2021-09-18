pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "./RarityInterface.sol";

contract RarityRock is Context, AccessControlEnumerable, ERC20Burnable, ERC20Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    mapping(uint => uint) public balancePerSummoner;
    
    RarityInterface private rarity;
    
    constructor(address _rarity) ERC20("Rarity Rock", "RARO") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        rarity = RarityInterface(_rarity);
    }
    
    function mint(uint summonerId, uint amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()));
        _mint(address(this), amount);
        balancePerSummoner[summonerId] += amount;
    }
    
    function withdraw(uint summonerId, uint amount) public virtual {
        require(_isApprovedOrOwner(summonerId));
        uint summonerBalance = balancePerSummoner[summonerId];
        require(summonerBalance >= amount);
        balancePerSummoner[summonerId] -= amount;
        _transfer(address(this), _msgSender(), amount);
    }
    
    function deposit(uint summonerId, uint amount) public virtual {
		require(_isApprovedOrOwner(summonerId));
        _transfer(_msgSender(), address(this), amount);
        balancePerSummoner[summonerId] += amount;
    }
    
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()));
        _pause();
    }
    
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()));
        _unpause();
    }

    function decimals() public view virtual override returns (uint8) { 
        return 1; 
    }
    
    function _beforeTokenTransfer(address from, address to, uint amount) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
    
    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return rarity.getApproved(_summoner) == _msgSender() || rarity.ownerOf(_summoner) == _msgSender();
    }
}
