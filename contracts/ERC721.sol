// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol"; 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol"; 

contract LabNFT is ERC721, EIP712,ERC2981, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {

    string constant private _name = "Lab Royalty NFT";
    string constant private _symbol = "LabNFT";
    string constant public version = "1.0.1";
    mapping(address => uint256) public nonce;
    constructor() ERC721(_name, _symbol) EIP712(_name, version) {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId, string calldata uri)
        external
        onlyOwner
    {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    bytes32 constant private MINT_STRUCT_HASH = keccak256("SafeMintWithSig(address to,uint256 tokenId,string uri,uint256 nonce)");

    function safeMintWithSig(address to, uint256 tokenId, string calldata uri, uint8 v, bytes32 r, bytes32 s)
        external
    {   
        bytes32 hash = keccak256(abi.encode(MINT_STRUCT_HASH, to, tokenId, uri, nonce[owner()]++));
        address signer = ECDSA.recover(_hashTypedDataV4(hash), v, r, s);
        require(signer == owner(), "unauthorized signer");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function setTokenURI(uint256 tokenId, string calldata uri) external onlyOwner{
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}