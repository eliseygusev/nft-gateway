// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.16;

import "../lib/solmate/src/tokens/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";

error DuckLocked();
error DoesntExist();
error NotAuthorized();

contract BridgedDuck is ERC721, Ownable {
    event Lock(address indexed from, string wavesAddress, string id);

    mapping(uint256 => string) public _nftStorage;
    mapping(uint256 => bool) isLocked;
    string public baseURI;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor(string memory _name, string memory _symbol, string memory _baseURI, address _owner)
        ERC721(_name, _symbol)
    {
        transferOwnership(_owner);
        baseURI = _baseURI;
    }

    function unlock(address to, uint256 id) external payable onlyOwner {
        isLocked[id] = false;
        transferFrom(msg.sender, to, id);
    }

    function mint(address to, string memory duckId) external payable onlyOwner returns (uint256 id) {
        id = _tokenIds.current();
        // Set the NFTs data.
        _nftStorage[id] = duckId;
        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();
        _safeMint(to, id);
    }

    function transferFrom(address from, address to, uint256 id) public override {
        if (isLocked[id]) {
            revert DuckLocked();
        }
        super.transferFrom(from, to, id);
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        if (id > _tokenIds.current()) {
            revert DoesntExist();
        }
        return string(abi.encodePacked(baseURI, _nftStorage[id]));
    }

    function sendBack(uint256 id, string memory wavesAddress) external payable {
        if (msg.sender != ownerOf(id)) {
            revert NotAuthorized();
        }
        if (!(msg.sender == getApproved[id] || isApprovedForAll[msg.sender][msg.sender])) {
            revert NotAuthorized();
        }
        transferFrom(msg.sender, owner(), id);
        isLocked[id] = true;
        emit Lock(msg.sender, wavesAddress, string(_nftStorage[id]));
    }
}
