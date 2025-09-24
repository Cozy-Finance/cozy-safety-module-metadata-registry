// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

import {Script} from "forge-std/Script.sol";
import {MetadataRegistry} from "../src/MetadataRegistry.sol";

/**
 * @notice Update the metadata for safety modules and controllers.
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
    // authorized to update metadata for all configured safety modules and controllers.
    bool updateSafetyModuleMetadata = true;
    bool updateControllerMetadata = true;

    // -------- SafetyModule Metadata --------

    address[] memory safetyModules_ = new address[](2);
    safetyModules_[0] = 0x0000000000000000000000000000000000000000;
    safetyModules_[1] = 0x0000000000000000000000000000000000000000;

    // This array should map 1:1 with the sets_ array.
    MetadataRegistry.Metadata[] memory safetyModuleMetadata_ = new MetadataRegistry.Metadata[](2);
    safetyModuleMetadata_[0] = MetadataRegistry.Metadata(
      "Mock Safety Module A",
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ac semper lectus. Ut vitae scelerisque metus.",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Ethereum_logo_2014.svg/628px-Ethereum_logo_2014.svg.png",
      ""
    );
    safetyModuleMetadata_[1] = MetadataRegistry.Metadata(
      "Mock Safety Module B",
      "In ac ipsum ex. Duis sagittis nibh ac volutpat venenatis. In dignissim elit et consequat ullamcorper.",
      "https://cryptologos.cc/logos/usd-coin-usdc-logo.png",
      ""
    );

    // -------- Controller Metadata --------

    address[] memory controllers_ = new address[](2);
    controllers_[0] = 0x0000000000000000000000000000000000000000;
    controllers_[1] = 0x0000000000000000000000000000000000000000;

    // This array should map 1:1 with the controllers_s array.
    MetadataRegistry.Metadata[] memory controllerMetadata_ = new MetadataRegistry.Metadata[](2);
    controllerMetadata_[0] = MetadataRegistry.Metadata(
      "Mock Hop", "Bridge", "Mock Bridge Protection", "https://cryptologos.cc/logos/terra-luna-luna-logo.png"
    );
    controllerMetadata_[1] = MetadataRegistry.Metadata(
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

    if (updateControllerMetadata) {
      vm.broadcast();
      metadataRegistry.updateControllerMetadata(controllers_, controllerMetadata_);
    }
  }
}
