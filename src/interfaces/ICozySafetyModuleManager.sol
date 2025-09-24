// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ISafetyModule} from "./ISafetyModule.sol";
import {ISafetyModuleController} from "./ISafetyModuleController.sol";

interface ICozySafetyModuleManager {
  /// @notice Returns the associated SafetyModule for the specified controller.
  function controllerRegistry(ISafetyModuleController controller_) external view returns (ISafetyModule);
}
