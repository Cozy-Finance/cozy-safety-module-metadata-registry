// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

interface ISafetyModule {
  /// @notice Returns the SafetyModule contract owner address.
  function owner() external view returns (address);
}
