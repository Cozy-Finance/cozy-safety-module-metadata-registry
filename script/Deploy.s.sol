// SPDX-License-Identifier: UNLICENSED
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

  address cozyRouter = address(0x2B505d6cEcc56AB1DBDc0245831694feB51c6569);
  address owner = address(0);

  // ----------------------------
  // -------- Deployment --------
  // ----------------------------

  function run() public {
    vm.broadcast();
    MetadataRegistry metadataRegistry = new MetadataRegistry(owner, cozyRouter);
    console2.log("MetadataRegistry deployed", address(metadataRegistry));
  }
}
