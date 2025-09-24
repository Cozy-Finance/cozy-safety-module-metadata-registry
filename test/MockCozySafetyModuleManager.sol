// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

import {ICozySafetyModuleManager} from "src/interfaces/ICozySafetyModuleManager.sol";
import {ISafetyModuleController} from "src/interfaces/ISafetyModuleController.sol";
import {ISafetyModule} from "src/interfaces/ISafetyModule.sol";

contract MockManager is ICozySafetyModuleManager {
  mapping(ISafetyModuleController => ISafetyModule) public controllerRegistry;

  function setControllerRegistry(ISafetyModuleController controller_, ISafetyModule safetyModule_) external {
    controllerRegistry[controller_] = safetyModule_;
  }
}
