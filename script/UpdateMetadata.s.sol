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
    bool updateSafetyModuleMetadata = true;
    bool updateTriggerMetadata = true;

    // -------- SafetyModule Metadata --------

    address[] memory safetyModules_ = new address[](2);
    safetyModules_[0] = 0x0000000000000000000000000000000000000000;
    safetyModules_[1] = 0x0000000000000000000000000000000000000000;

    // This array should map 1:1 with the sets_ array.
    MetadataRegistry.SafetyModuleMetadata[] memory safetyModuleMetadata_ =
      new MetadataRegistry.SafetyModuleMetadata[](2);
    safetyModuleMetadata_[0] = MetadataRegistry.SafetyModuleMetadata(
      "Mock Safety Module A",
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ac semper lectus. Ut vitae scelerisque metus.",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Ethereum_logo_2014.svg/628px-Ethereum_logo_2014.svg.png"
    );
    safetyModuleMetadata_[1] = MetadataRegistry.SafetyModuleMetadata(
      "Mock Safety Module B",
      "In ac ipsum ex. Duis sagittis nibh ac volutpat venenatis. In dignissim elit et consequat ullamcorper.",
      "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"
    );

    // -------- Trigger Metadata --------

    address[] memory triggers_ = new address[](2);
    triggers_[0] = 0x0000000000000000000000000000000000000000;
    triggers_[1] = 0x0000000000000000000000000000000000000000;

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

    if (updateSafetyModuleMetadata) {
      vm.broadcast();
      metadataRegistry.updateSafetyModuleMetadata(safetyModules_, safetyModuleMetadata_);
    }

    if (updateTriggerMetadata) {
      vm.broadcast();
      metadataRegistry.updateTriggerMetadata(triggers_, triggerMetadata_);
    }
  }
}
