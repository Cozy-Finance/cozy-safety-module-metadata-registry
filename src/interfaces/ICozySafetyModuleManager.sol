// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ISafetyModule} from "./ISafetyModule.sol";

interface ICozySafetyModuleManager {
  /// @notice Returns the associated SafetyModule for the specified controller.
  function controllerRegistry(address controller_) external view returns (ISafetyModule);
}
