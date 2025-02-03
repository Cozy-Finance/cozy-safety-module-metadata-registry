// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

interface ISharedSafetyModuleCoordinator {
  function isActiveOwner(address owner_) external view returns (bool isActiveOwner_);
}
