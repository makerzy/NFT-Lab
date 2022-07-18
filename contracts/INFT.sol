// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface INFTEIP712EIP191{

function initialized(address) external;
function owner()external view returns(address);
}