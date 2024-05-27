// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {MetadataRegistry} from "src/MetadataRegistry.sol";

/**
 * @notice *Purpose: Local deploy, testing, and production.*
 *
 * This script deploys the Cozy MetadataRegistry. Before running this script, the cozyRouter and owner addresses
 * should be updated in the configuration section of the script.
 *
 * To run this script:
 *
 * ```sh
 * # Start anvil, forking from the current state of the desired chain.
 * anvil --fork-url $OPTIMISM_RPC_URL
 *
 * # In a separate terminal, perform a dry run the script.
 * forge script script/Deploy.s.sol \
 *   --rpc-url "http://127.0.0.1:8545" \
 *   -vvvv
 *
 * # Or, to broadcast a transaction.
 * forge script script/Deploy.s.sol \
 *   --rpc-url "http://127.0.0.1:8545" \
 *   --private-key $OWNER_PRIVATE_KEY \
 *   --broadcast \
 *   -vvvv
 * ```
 */
contract Deploy is Script {
  // -------------------------------
  // -------- Configuration --------
  // -------------------------------

  address cozyRouter = address(0x4EF749A024Db75cc04C9D2619DDF55f31d9876E4);
  address owner = address(0x1b8F0B53D1c352B3E774e3f5C9F8E28F19CdCD7b);

  // ----------------------------
  // -------- Deployment --------
  // ----------------------------

  function run() public {
    console2.log("CozyRouter", cozyRouter);
    console2.log("Owner", owner);
    vm.broadcast();
    MetadataRegistry metadataRegistry = new MetadataRegistry(owner, cozyRouter);
    console2.log("MetadataRegistry deployed", address(metadataRegistry));
  }
}
