// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "forge-std/Script.sol";

contract ScriptUtils is Script {
  using stdJson for string;

  string INPUT_FOLDER = "/script/input/";

  // Returns the json string for the specified filename from `INPUT_FOLDER`.
  function readInput(string memory fileName_) internal view returns (string memory) {
    string memory root_ = vm.projectRoot();
    string memory chainInputFolder_ = string.concat(INPUT_FOLDER, vm.toString(block.chainid), "/");
    string memory inputFile_ = string.concat(fileName_, ".json");
    string memory inputPath_ = string.concat(root_, chainInputFolder_, inputFile_);
    return vm.readFile(inputPath_);
  }
}
