// // SPDX-License-Identifier: MIT
// pragma solidity ^0.6.6;

// import "forge-std/Script.sol";
// import "../contracts/ProphetRouterV1.sol";  // Replace with the path to your contract

// contract DeployScript is Script {
//     function run() external {
//         vm.startBroadcast();

//         // Set your desired gas limit here
//         uint256 gasLimit = 5000000; // Example gas limit, adjust as needed

//         // Deploy the contract
//         ProphetRouterV1 yourContract = new ProphetRouterV1{gas: gasLimit}();

//         vm.stopBroadcast();
//     }
// }
// //forge script script/Counter.s.sol:DeployScript --rpc-url https://mainnet.infura.io/v3/7214c971517a4856a1ea3c32a5ba8bd0 --broadcast -vvv
