// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Ownable.sol";
import "./INFT.sol";


contract NFTFactory is Ownable{
  address[] private _allNFTs;
  mapping(address=> address) public userNFT; // user address => contract address

  address public nftImplementation;

    constructor(address _nftImplementation) {
        nftImplementation = _nftImplementation;
        _transferOwnership(_msgSender());
    }

     function getAllNFTs() external view returns (address[] memory) {
        return _allNFTs;
    }


    event UpdateImplementation(address sender, address nftImpl);

    function updateImplementation(address _nftImpl) external {
       onlyOwner();
        nftImplementation = _nftImpl;
        emit UpdateImplementation(_msgSender(), nftImplementation);
    }


    event NftCreated(address sender, address nft, uint256 storeCount);

    function createNFT(    ) external returns (address nft) {
        bytes32 salt = keccak256(
            abi.encode(
                _msgSender(),
                nftImplementation,
                address(this),
                block.timestamp
            )
        );
        nft = Clones.cloneDeterministic(nftImplementation, salt);
        INFTEIP712EIP191(nft).initialized(_msgSender());
        userNFT[_msgSender()] = nft;
        _allNFTs.push(nft);
        emit NftCreated(_msgSender(), nft, _allNFTs.length);
    }

}


