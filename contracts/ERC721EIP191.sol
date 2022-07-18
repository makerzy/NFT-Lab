// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract NFTEIP712EIP191 is ERC721, EIP712,ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    string private constant _name="NFT EIP191&EIP712";
    string private constant _version="1.0.1";
    string private constant _symbol="NFT";
    mapping(address => uint256) public nonce;
    bool _initialized = false;

    constructor() ERC721(_name, _symbol)EIP712(_name, _version) {
        
    }

    function initialized(address _owner) external {
        require(!_initialized, "initialized");
        _initialized = true;
        _transferOwnership(_owner);

    }

    function domainSeparator() external view returns(bytes32){
        return _domainSeparatorV4();
    }

    bytes32 public constant MINT_STRUCT_HASH =
        keccak256(
            "SafeMintWithSig(address to,uint256 tokenId,string uri,uint256 nonce)"
        );

    function safeMintWithSig(
        address to,
        uint256 tokenId,
        string calldata uri,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        uint256 _nonce = ++nonce[owner()];
        bytes32 hash = keccak256(
            abi.encode(
                MINT_STRUCT_HASH,
                to,
                tokenId,
                keccak256(bytes(uri)),
                _nonce
            )
        );
        bytes32 eip191Hash = keccak256(
            abi.encodePacked(
            _domainSeparatorV4(),
            MINT_STRUCT_HASH,
            to, tokenId,bytes(uri), _nonce));
        address signer = ECDSA.recover(_hashTypedDataV4(hash), v, r, s);
        address personal_signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(eip191Hash), v, r, s);
        require(signer == owner() || personal_signer == owner(), "unauthorized signer");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function safeMint(address to, uint256 tokenId, string memory uri)
        public
        
    {
        onlyOwner();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    
    bytes32 public constant SAFE_TRANSFER_SIG = keccak256("safeTransferFromSig(address to,uint256 tokenId,uint256 nonce)");

    function safeTransferFromSig(address signatory,address to, uint256 tokenId, uint8 v, bytes32 r, bytes32 s)external {
        uint256 _nonce = ++nonce[signatory];
        bytes32 hash = keccak256(abi.encode(SAFE_TRANSFER_SIG, to, tokenId,_nonce));
        address signer = ECDSA.recover(_hashTypedDataV4(hash), v, r, s);
        bytes32 eip191Hash = keccak256(
            abi.encodePacked(
            _domainSeparatorV4(),
            SAFE_TRANSFER_SIG,
            to, tokenId, _nonce));
        address personal_signer =ECDSA.recover(ECDSA.toEthSignedMessageHash(eip191Hash), v, r, s);
        address owner = ERC721.ownerOf(tokenId);
        
        require(owner == personal_signer || owner == signer, "unauthorized action");
        require(signatory==owner, "signatory must be owner");
        _safeTransfer(owner, to, tokenId, "");
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

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
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}