// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

interface ISafetyModule {
  /// @notice Returns the SafetyModule contract owner address.
  function owner() external view returns (address);
}
