// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {ITrigger} from "./interfaces/ITrigger.sol";
import {ISafetyModule} from "./interfaces/ISafetyModule.sol";

/**
 * @notice Emits metadata about a safety module or trigger so it can be retrieved off-chain.
 * @dev Metadata can be fetched by querying logs or configuring a subgraph to index the events.
 */
contract MetadataRegistry {
  // Required metadata for a given safety module.
  struct SafetyModuleMetadata {
    string name; // Name of the safety module.
    string description; // Description of the safety module.
    string logoURI; // Path to a logo for the safety module.
  }

  // Required metadata for a given trigger.
  struct TriggerMetadata {
    string name; // Name of the trigger.
    string category; // Category of the trigger.
    string description; // Description of the trigger.
    string logoURI; // Path to a logo for the trigger.
  }

  /// @dev Emitted when a safety module's metadata is updated.
  event SafetyModuleMetadataUpdated(address indexed safetyModule, SafetyModuleMetadata metadata);

  /// @dev Emitted when a trigger's metadata is updated.
  event TriggerMetadataUpdated(address indexed trigger, TriggerMetadata metadata);

  /// @dev Thrown when the caller is not authorized to perform the action.
  error Unauthorized();

  /// @dev Thrown when there is a length mismatch in the provided metadata.
  error InvalidConfiguration();

  /// @notice Update metadata for safety modules.
  /// @param safetyModules_ An array of safety modules to be updated.
  /// @param metadata_ An array of new metadata, mapping 1:1 with the addresses in the safetyModules_ array.
  function updateSafetyModuleMetadata(address[] calldata safetyModules_, SafetyModuleMetadata[] calldata metadata_)
    external
  {
    if (safetyModules_.length != metadata_.length) revert InvalidConfiguration();
    for (uint256 i = 0; i < safetyModules_.length; i++) {
      updateSafetyModuleMetadata(safetyModules_[i], metadata_[i]);
    }
  }

  /// @notice Update metadata for a safety module.
  /// @param safetyModule_ The address of the safety module.
  /// @param metadata_ The new metadata for the safety module.
  function updateSafetyModuleMetadata(address safetyModule_, SafetyModuleMetadata calldata metadata_) public {
    if (msg.sender != ISafetyModule(safetyModule_).owner()) revert Unauthorized();
    emit SafetyModuleMetadataUpdated(safetyModule_, metadata_);
  }

  /// @notice Update metadata for triggers.
  /// @param triggers_ An array of triggers to be updated.
  /// @param metadata_ An array of new metadata, mapping 1:1 with the addresses in the triggers_ array.
  function updateTriggerMetadata(address[] calldata triggers_, TriggerMetadata[] calldata metadata_) external {
    if (triggers_.length != metadata_.length) revert InvalidConfiguration();
    for (uint256 i = 0; i < triggers_.length; i++) {
      updateTriggerMetadata(triggers_[i], metadata_[i]);
    }
  }

  /// @notice Update metadata for a trigger.
  /// @param trigger_ The address of the trigger.
  /// @param metadata_ The new metadata for the trigger.
  function updateTriggerMetadata(address trigger_, TriggerMetadata calldata metadata_) public {
    address boss_ = address(0);
    address owner_ = address(0);

    try ITrigger(trigger_).boss() returns (address result_) {
      boss_ = result_;
    } catch {}

    try ITrigger(trigger_).owner() returns (address result_) {
      owner_ = result_;
    } catch {}

    if (msg.sender != boss_ && msg.sender != owner_) revert Unauthorized();
    emit TriggerMetadataUpdated(address(trigger_), metadata_);
  }
}