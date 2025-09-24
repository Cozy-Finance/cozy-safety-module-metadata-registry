// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

import {ICozySafetyModuleManager} from "src/interfaces/ICozySafetyModuleManager.sol";
import {ISafetyModule} from "src/interfaces/ISafetyModule.sol";

contract MockManager is ICozySafetyModuleManager {
  mapping(address => ISafetyModule) public controllerRegistry;

  function setControllerRegistry(address controller_, ISafetyModule safetyModule_) external {
    controllerRegistry[controller_] = safetyModule_;
  }
}
