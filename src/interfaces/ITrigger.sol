// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

/**
 * @dev Interface for interacting with triggers that might have privileged users.
 * This is not a comprehensive interface for triggers, and only contains signatures for privileged
 * roles that may exist.
 */
interface ITrigger {
  function boss() external view returns (address);
  function owner() external view returns (address);
}
