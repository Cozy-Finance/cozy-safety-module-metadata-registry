// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

import {ISafetyModuleController} from "./interfaces/ISafetyModuleController.sol";
import {ISafetyModule} from "./interfaces/ISafetyModule.sol";
import {ISharedSafetyModuleCoordinator} from "./interfaces/ISharedSafetyModuleCoordinator.sol";
import {ICozySafetyModuleManager} from "./interfaces/ICozySafetyModuleManager.sol";

/**
 * @notice Emits metadata about a safety module or trigger so it can be retrieved off-chain.
 * @dev Metadata can be fetched by querying logs or configuring a subgraph to index the events.
 */
contract MetadataRegistry {
  /// @notice The CozyRouter address used by this MetadataRegistry.
  address public cozyRouter;

  /// @notice The CozySafetyModuleManager address used by this MetadataRegistry.
  address public cozySafetyModuleManager;

  /// @notice The owner of this MetadataRegistry.
  address public owner;

  struct Metadata {
    string name;
    string description;
    string logoURI;
    string extraData;
  }

  /// @dev Emitted when the CozyRouter is updated.
  event CozyRouterUpdated(address indexed cozyRouter);

  /// @dev Emitted when the CozySafetyModuleManager is updated.
  event CozySafetyModuleManagerUpdated(address indexed cozySafetyModuleManager);

  /// @dev Emitted when the owner is updated.
  event OwnerUpdated(address indexed owner);

  /// @dev Emitted when a safety module's metadata is updated.
  event SafetyModuleMetadataUpdated(address indexed safetyModule, Metadata metadata);

  /// @dev Emitted when a shared safety module's metadata is updated.
  event SharedSafetyModuleCoordinatorMetadataUpdated(address indexed sharedSafetyModuleCoordinator, Metadata metadata);

  /// @dev Emitted when a controller's metadata is updated.
  event ControllerMetadataUpdated(address indexed controller, Metadata metadata);

  /// @dev Thrown when the caller is not authorized to perform the action.
  error Unauthorized();

  /// @dev Thrown when there is a length mismatch in the provided metadata.
  error InvalidConfiguration();

  constructor(address owner_, address cozyRouter_, address cozySafetyModuleManager_) {
    owner = owner_;
    cozyRouter = cozyRouter_;
    cozySafetyModuleManager = cozySafetyModuleManager_;
  }

  /// @notice Update metadata for safety modules.
  /// @param safetyModules_ An array of safety modules to be updated.
  /// @param metadata_ An array of new metadata, mapping 1:1 with the addresses in the safetyModules_ array.
  function updateSafetyModuleMetadata(address[] calldata safetyModules_, Metadata[] calldata metadata_) external {
    if (safetyModules_.length != metadata_.length) revert InvalidConfiguration();
    for (uint256 i = 0; i < safetyModules_.length; i++) {
      updateSafetyModuleMetadata(safetyModules_[i], metadata_[i]);
    }
  }

  /// @notice Update metadata for a safety module.
  /// @param safetyModule_ The address of the safety module.
  /// @param metadata_ The new metadata for the safety module.
  function updateSafetyModuleMetadata(address safetyModule_, Metadata calldata metadata_) public {
    if (msg.sender != ISafetyModule(safetyModule_).owner()) revert Unauthorized();
    emit SafetyModuleMetadataUpdated(safetyModule_, metadata_);
  }

  /// @notice Update metadata for a safety module. This function can be called by the CozyRouter.
  /// @param safetyModule_ The address of the safety module.
  /// @param metadata_ The new metadata for the safety module.
  /// @param caller_ The address of the CozyRouter caller.
  function updateSafetyModuleMetadata(address safetyModule_, Metadata calldata metadata_, address caller_) public {
    if (msg.sender != cozyRouter || caller_ != ISafetyModule(safetyModule_).owner()) revert Unauthorized();
    emit SafetyModuleMetadataUpdated(safetyModule_, metadata_);
  }

  /// @notice Update metadata for shared safety modules.
  /// @param sharedSafetyModuleCoordinators_ An array of shared safety modules to be updated.
  /// @param metadata_ An array of new metadata, mapping 1:1 with the addresses in the sharedSafetyModuleCoordinators_
  /// array.
  function updateSharedSafetyModuleCoordinatorMetadata(
    address[] calldata sharedSafetyModuleCoordinators_,
    Metadata[] calldata metadata_
  ) external {
    if (sharedSafetyModuleCoordinators_.length != metadata_.length) revert InvalidConfiguration();
    for (uint256 i = 0; i < sharedSafetyModuleCoordinators_.length; i++) {
      updateSharedSafetyModuleCoordinatorMetadata(sharedSafetyModuleCoordinators_[i], metadata_[i]);
    }
  }

  /// @notice Update metadata for a shared safety module coordinator.
  /// @param sharedSafetyModuleCoordinator_ The address of the shared safety module coordinator.
  /// @param metadata_ The new metadata for the shared safety module coordinator.
  function updateSharedSafetyModuleCoordinatorMetadata(
    address sharedSafetyModuleCoordinator_,
    Metadata calldata metadata_
  ) public {
    if (!ISharedSafetyModuleCoordinator(sharedSafetyModuleCoordinator_).isActiveOwner(msg.sender)) {
      revert Unauthorized();
    }
    emit SharedSafetyModuleCoordinatorMetadataUpdated(sharedSafetyModuleCoordinator_, metadata_);
  }

  /// @notice Update metadata for a shared safety module. This function can be called by the CozyRouter.
  /// @param sharedSafetyModuleCoordinator_ The address of the shared safety module coordinator.
  /// @param metadata_ The new metadata for the safety module.
  /// @param caller_ The address of the CozyRouter caller.
  function updateSharedSafetyModuleCoordinatorMetadata(
    address sharedSafetyModuleCoordinator_,
    Metadata calldata metadata_,
    address caller_
  ) public {
    if (
      msg.sender != cozyRouter || !ISharedSafetyModuleCoordinator(sharedSafetyModuleCoordinator_).isActiveOwner(caller_)
    ) revert Unauthorized();
    emit SharedSafetyModuleCoordinatorMetadataUpdated(sharedSafetyModuleCoordinator_, metadata_);
  }

  /// @notice Update metadata for controllers.
  /// @param controllers_ An array of controllers to be updated.
  /// @param metadata_ An array of new metadata, mapping 1:1 with the addresses in the controllers_ array.
  function updateControllerMetadata(address[] calldata controllers_, Metadata[] calldata metadata_) external {
    if (controllers_.length != metadata_.length) revert InvalidConfiguration();
    for (uint256 i = 0; i < controllers_.length; i++) {
      updateControllerMetadata(controllers_[i], metadata_[i]);
    }
  }

  /// @notice Update metadata for a controller.
  /// @param controller_ The address of the controller.
  /// @param metadata_ The new metadata for the controller.
  function updateControllerMetadata(address controller_, Metadata calldata metadata_) public {
    if (
      msg.sender
        != ICozySafetyModuleManager(cozySafetyModuleManager).controllerRegistry(ISafetyModuleController(controller_))
          .owner()
    ) revert Unauthorized();
    emit ControllerMetadataUpdated(controller_, metadata_);
  }

  /// @notice Update metadata for a controller. This function can be called by the CozyRouter.
  /// @param controller_ The address of the controller.
  /// @param metadata_ The new metadata for the controller.
  /// @param caller_ The address of the CozyRouter caller.
  function updateControllerMetadata(address controller_, Metadata calldata metadata_, address caller_) public {
    if (
      msg.sender != cozyRouter
        || caller_
          != ICozySafetyModuleManager(cozySafetyModuleManager).controllerRegistry(ISafetyModuleController(controller_))
            .owner()
    ) revert Unauthorized();
    emit ControllerMetadataUpdated(controller_, metadata_);
  }

  /// @notice Update the CozyRouter address used by this MetadataRegistry.
  /// @param cozyRouter_ The new CozyRouter address.
  function updateCozyRouter(address cozyRouter_) external onlyOwner {
    cozyRouter = cozyRouter_;
    emit CozyRouterUpdated(cozyRouter_);
  }

  /// @notice Update the CozySafetyModuleManager address used by this MetadataRegistry.
  /// @param cozySafetyModuleManager_ The new CozySafetyModuleManager address.
  function updateCozySafetyModuleManager(address cozySafetyModuleManager_) external onlyOwner {
    cozySafetyModuleManager = cozySafetyModuleManager_;
    emit CozySafetyModuleManagerUpdated(cozySafetyModuleManager_);
  }

  function updateOwner(address owner_) external onlyOwner {
    owner = owner_;
    emit OwnerUpdated(owner_);
  }

  modifier onlyOwner() {
    if (msg.sender != owner) revert Unauthorized();
    _;
  }
}
