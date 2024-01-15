// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import {Script} from "forge-std/Script.sol";
import {MetadataRegistry} from "../src/MetadataRegistry.sol";

/**
 * @notice Update the metadata for safety modules and triggers.
 * @dev Update the Configuration section below before running this script.
 */
contract UpdateMetadata is Script {
  function run() public {
    // -------------------------------
    // -------- Configuration --------
    // -------------------------------

    MetadataRegistry metadataRegistry = MetadataRegistry(0x0000000000000000000000000000000000000000);

    // Flags to specify which update transactions should be executed.
    // NOTE: If both flags are true, the private key being used to run this script must be
    // authorized to update metadata for all configured safety modules and triggers.
    bool updateSetMetadata = true;
    bool updateTriggerMetadata = true;

    // -------- Set Metadata --------

    address[] memory safetyModules_ = new address[](2);
    safetyModules_[0] = 0x070E9538123e26543842EAA723c81d6c2A92A296;
    safetyModules_[1] = 0x05585408234dec93F475dA4271f95d6138908bA6;

    // This array should map 1:1 with the sets_ array.
    MetadataRegistry.SafetyModuleMetadata[] memory setMetadata_ = new MetadataRegistry.SafetyModuleMetadata[](2);
    setMetadata_[0] = MetadataRegistry.SafetyModuleMetadata(
      "Mock Safety Module A",
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ac semper lectus. Ut vitae scelerisque metus.",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Ethereum_logo_2014.svg/628px-Ethereum_logo_2014.svg.png"
    );
    setMetadata_[1] = MetadataRegistry.SafetyModuleMetadata(
      "Mock Safety Module B",
      "In ac ipsum ex. Duis sagittis nibh ac volutpat venenatis. In dignissim elit et consequat ullamcorper.",
      "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"
    );

    // -------- Trigger Metadata --------

    address[] memory triggers_ = new address[](2);
    triggers_[0] = 0x89627112EaCD324Af941E203Cac196ABd4fc2EF5;
    triggers_[1] = 0x875106C596f897c1FB42169506F49Df641d286b0;

    // This array should map 1:1 with the triggers_ array.
    MetadataRegistry.TriggerMetadata[] memory triggerMetadata_ = new MetadataRegistry.TriggerMetadata[](2);
    triggerMetadata_[0] = MetadataRegistry.TriggerMetadata(
      "Mock Hop", "Bridge", "Mock Bridge Protection", "https://cryptologos.cc/logos/terra-luna-luna-logo.png"
    );
    triggerMetadata_[1] = MetadataRegistry.TriggerMetadata(
      "Mock Compound Finance",
      "Lending",
      "Mock Protocol Protection",
      "https://cryptologos.cc/logos/compound-comp-logo.png"
    );

    // ---------------------------
    // -------- Execution --------
    // ---------------------------

    if (updateSetMetadata) {
      vm.broadcast();
      metadataRegistry.updateSafetyModuleMetadata(safetyModules_, setMetadata_);
    }

    if (updateTriggerMetadata) {
      vm.broadcast();
      metadataRegistry.updateTriggerMetadata(triggers_, triggerMetadata_);
    }
  }
}
