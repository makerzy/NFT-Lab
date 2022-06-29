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

contract LabNFT is
    ERC721,
    EIP712,
    ERC2981,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable
{
    string private constant _name = "Lab Royalty NFT";
    string private constant _symbol = "LabNFT";
    string public constant version = "1.0.1";
    mapping(address => uint256) public nonce;
    uint96 public royalty = 500;
    bytes32 private constant MINT_STRUCT_HASH =
        keccak256(
            "SafeMintWithSig(address to,uint256 tokenId,string uri,uint256 nonce)"
        );

    constructor() ERC721(_name, _symbol) EIP712(_name, version) {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function safeMint(
        address to,
        uint256 tokenId,
        string calldata uri
    ) external onlyOwner {
        _safeMint(to, tokenId);
        _setTokenRoyalty(tokenId, owner(), royalty);
        _setTokenURI(tokenId, uri);
    }

    function safeMintWithSig(
        address to,
        uint256 tokenId,
        string calldata uri,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // nonce[owner()] =nonce[owner()]+ 1;
        bytes32 hash = keccak256(
            abi.encode(
                MINT_STRUCT_HASH,
                to,
                tokenId,
                keccak256(bytes(uri)),
                ++nonce[owner()]
            )
        );
        address signer = ECDSA.recover(_hashTypedDataV4(hash), v, r, s);
        require(signer == owner(), "unauthorized signer");
        _safeMint(to, tokenId);
        _setTokenRoyalty(tokenId, owner(), royalty);
        _setTokenURI(tokenId, uri);
    }

    function setTokenURI(uint256 tokenId, string calldata uri)
        external
        onlyOwner
    {
        _setTokenURI(tokenId, uri);
    }

    function setTokenRoyalty(address receivingWallet, uint256 tokenId) onlyOwner external{
        _setTokenRoyalty(tokenId, receivingWallet, royalty);
    }

    function updateRoyalty(uint96 _royalty) onlyOwner external{
        royalty = _royalty;

    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
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
        return
            super.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }
}
