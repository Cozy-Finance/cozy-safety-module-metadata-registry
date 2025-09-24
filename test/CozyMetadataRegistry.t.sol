// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import "forge-std/Test.sol";
import {MetadataRegistry} from "../src/MetadataRegistry.sol";
import {ISafetyModule} from "../src/interfaces/ISafetyModule.sol";
import {ISafetyModuleController} from "../src/interfaces/ISafetyModuleController.sol";

contract MetadataRegistryTestSetup is Test {
  MetadataRegistry metadataRegistry;

  address cozyRouter;
  address boss;
  address owner;
  address localOwner;
  address metadataRegistryOwner;

  address controllerA;
  address controllerB;

  event CozyRouterUpdated(address indexed cozyRouter);
  event OwnerUpdated(address indexed owner);
  event SafetyModuleMetadataUpdated(address indexed safetyModule, MetadataRegistry.Metadata metadata);
  event ControllerMetadataUpdated(address indexed controller, MetadataRegistry.Metadata metadata);

  function setUp() public {
    cozyRouter = makeAddr("cozyRouter");
    boss = makeAddr("boss");
    owner = makeAddr("owner");
    localOwner = makeAddr("localOwner");
    metadataRegistryOwner = makeAddr("metadataRegistryOwner");

    controllerA = makeAddr("controllerA");
    controllerB = makeAddr("controllerB");

    // Mock controller responses.
    vm.mockCall(address(controllerA), abi.encodeWithSelector(ISafetyModuleController.boss.selector), abi.encode(boss));
    vm.mockCall(address(controllerB), abi.encodeWithSelector(ISafetyModuleController.boss.selector), abi.encode(boss));
    vm.mockCall(address(controllerA), abi.encodeWithSelector(ISafetyModuleController.owner.selector), abi.encode(owner));
    vm.mockCall(address(controllerB), abi.encodeWithSelector(ISafetyModuleController.owner.selector), abi.encode(owner));

    // Deploy metadata registry.
    metadataRegistry = new MetadataRegistry(metadataRegistryOwner, cozyRouter);
  }
}

contract MetadataRegistryTest is MetadataRegistryTestSetup {
  function test_UpdateSafetyModuleMetadata() public {
    testFuzz_UpdateSafetyModuleMetadata(
      "Alice's Safety Module",
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ac semper lectus. Ut vitae scelerisque metus. \
      Quisque congue semper purus et faucibus. Pellentesque nec justo nec metus rutrum porta in eget tellus. Mauris ornare \
      odio enim, a accumsan lacus commodo quis. Cras elementum risus in dolor ultrices, auctor commodo leo aliquet. Etiam \
      posuere odio ut hendrerit egestas. Vestibulum auctor placerat dui quis consequat. Donec non diam sit amet tellus \
      congue hendrerit. Curabitur eu dui felis. Phasellus ut pulvinar erat. Proin nec nibh eu dolor cursus auctor. \
      Praesent in quam nec nisl posuere blandit. Suspendisse finibus nisi sit amet metus efficitur commodo. Vestibulum \
      ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae",
      "https://www.google.com/images/branding/googlelogo/2x/googlelogo_light_color_92x30dp.png",
      "$category: Category"
    );
  }

  function testFuzz_UpdateSafetyModuleMetadata(
    string memory _name,
    string memory _description,
    string memory _logo,
    string memory _extraData
  ) public {
    MetadataRegistry.Metadata[] memory _metadata = new MetadataRegistry.Metadata[](2);
    _metadata[0] = MetadataRegistry.Metadata(_name, _description, _logo, _extraData);
    _metadata[1] = MetadataRegistry.Metadata(
      "Bob's Safety Module",
      "A sweet Safety Module",
      "https://www.google.com/images/branding/googlelogo/2x/googlelogo_light_color_92x30dp.png",
      _extraData
    );

    address[] memory _safetyModules = new address[](2);
    _safetyModules[0] = makeAddr("sm0");
    _safetyModules[1] = makeAddr("sm1");

    // Mock safetyModule.owner responses.
    vm.mockCall(_safetyModules[0], abi.encodeWithSelector(ISafetyModule.owner.selector), abi.encode(localOwner));
    vm.mockCall(_safetyModules[1], abi.encodeWithSelector(ISafetyModule.owner.selector), abi.encode(localOwner));

    vm.expectEmit(true, true, true, true);
    emit SafetyModuleMetadataUpdated(_safetyModules[0], _metadata[0]);
    vm.expectEmit(true, true, true, true);
    emit SafetyModuleMetadataUpdated(_safetyModules[1], _metadata[1]);
    vm.prank(localOwner);
    metadataRegistry.updateSafetyModuleMetadata(_safetyModules, _metadata);
  }

  function testFuzz_UpdateSafetyModuleMetadataFromRouter(
    string memory _name,
    string memory _description,
    string memory _logo,
    string memory _extraData
  ) public {
    MetadataRegistry.Metadata memory _metadata = MetadataRegistry.Metadata(_name, _description, _logo, _extraData);

    address _safetyModule = makeAddr("sm0");

    // Mock safetyModule.owner response.
    vm.mockCall(_safetyModule, abi.encodeWithSelector(ISafetyModule.owner.selector), abi.encode(localOwner));

    vm.expectEmit(true, true, true, true);
    emit SafetyModuleMetadataUpdated(_safetyModule, _metadata);
    vm.prank(cozyRouter);
    metadataRegistry.updateSafetyModuleMetadata(_safetyModule, _metadata, localOwner);
  }

  function testFuzz_UpdateSafetyModuleMetadataUnauthorized(
    address _who,
    string memory _name,
    string memory _description,
    string memory _logo,
    string memory _extraData
  ) public {
    vm.assume(_who != localOwner);
    MetadataRegistry.Metadata[] memory _metadata = new MetadataRegistry.Metadata[](1);
    _metadata[0] = MetadataRegistry.Metadata(_name, _description, _logo, _extraData);
    address[] memory _safetyModules = new address[](1);
    _safetyModules[0] = makeAddr("sm0");
    vm.mockCall(
      _safetyModules[0], abi.encodeWithSelector(ISafetyModule.owner.selector), abi.encode(makeAddr("randomAddr"))
    );
    vm.prank(_who);
    vm.expectRevert(MetadataRegistry.Unauthorized.selector);
    metadataRegistry.updateSafetyModuleMetadata(_safetyModules, _metadata);
  }

  function testFuzz_UpdateSafetyModuleMetadataFromRouterUnauthorized(
    address _who,
    string memory _name,
    string memory _description,
    string memory _logo,
    string memory _extraData
  ) public {
    vm.assume(_who != localOwner);
    MetadataRegistry.Metadata memory _metadata = MetadataRegistry.Metadata(_name, _description, _logo, _extraData);

    address _safetyModule = makeAddr("sm0");

    // Mock safetyModule.owner response.
    vm.mockCall(_safetyModule, abi.encodeWithSelector(ISafetyModule.owner.selector), abi.encode(localOwner));

    vm.prank(cozyRouter);
    vm.expectRevert(MetadataRegistry.Unauthorized.selector);
    metadataRegistry.updateSafetyModuleMetadata(_safetyModule, _metadata, _who); // _who must be the owner of the SM.

    vm.prank(_who); // The caller must be the CozyRouter.
    vm.expectRevert(MetadataRegistry.Unauthorized.selector);
    metadataRegistry.updateSafetyModuleMetadata(_safetyModule, _metadata, _who);
  }

  function test_UpdateControllerMetadata() public {
    testFuzz_UpdateControllerMetadata(
      "Alice's Controller",
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ac semper lectus. Ut vitae scelerisque metus. \
      Quisque congue semper purus et faucibus. Pellentesque nec justo nec metus rutrum porta in eget tellus. Mauris ornare \
      odio enim, a accumsan lacus commodo quis. Cras elementum risus in dolor ultrices, auctor commodo leo aliquet. Etiam \
      posuere odio ut hendrerit egestas. Vestibulum auctor placerat dui quis consequat. Donec non diam sit amet tellus \
      congue hendrerit. Curabitur eu dui felis. Phasellus ut pulvinar erat. Proin nec nibh eu dolor cursus auctor. \
      Praesent in quam nec nisl posuere blandit. Suspendisse finibus nisi sit amet metus efficitur commodo. Vestibulum \
      ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae",
      "https://www.google.com/images/branding/googlelogo/2x/googlelogo_light_color_92x30dp.png",
      "$category: Category"
    );
  }

  function testFuzz_UpdateControllerMetadata(
    string memory _name,
    string memory _description,
    string memory _logo,
    string memory _extraData
  ) public {
    MetadataRegistry.Metadata[] memory _metadata = new MetadataRegistry.Metadata[](2);
    _metadata[0] = MetadataRegistry.Metadata(_name, _description, _logo, _extraData);
    _metadata[1] = MetadataRegistry.Metadata(
      "Bob's Controller",
      "A sweet controller",
      "https://www.google.com/images/branding/googlelogo/2x/googlelogo_light_color_92x30dp.png",
      "Some extra data"
    );

    address[] memory _controllers = new address[](2);
    _controllers[0] = address(controllerA);
    _controllers[1] = address(controllerB);

    vm.expectEmit(true, true, true, true);
    emit ControllerMetadataUpdated(address(controllerA), _metadata[0]);
    vm.expectEmit(true, true, true, true);
    emit ControllerMetadataUpdated(address(controllerB), _metadata[1]);
    vm.prank(boss);
    metadataRegistry.updateControllerMetadata(_controllers, _metadata);

    vm.expectEmit(true, true, true, true);
    emit ControllerMetadataUpdated(address(controllerA), _metadata[0]);
    vm.expectEmit(true, true, true, true);
    emit ControllerMetadataUpdated(address(controllerB), _metadata[1]);
    vm.prank(owner);
    metadataRegistry.updateControllerMetadata(_controllers, _metadata);
  }

  function testFuzz_UpdateControllerMetadataUnauthorized(
    address _who,
    string memory _name,
    string memory _description,
    string memory _logo,
    string memory _extraData
  ) public {
    vm.assume(_who != owner && _who != boss && _who != address(0));
    MetadataRegistry.Metadata[] memory _metadata = new MetadataRegistry.Metadata[](1);
    _metadata[0] = MetadataRegistry.Metadata(_name, _description, _logo, _extraData);
    address[] memory _controllers = new address[](1);
    _controllers[0] = address(controllerA);

    vm.prank(_who);
    vm.expectRevert(MetadataRegistry.Unauthorized.selector);
    metadataRegistry.updateControllerMetadata(_controllers, _metadata);
  }

  function test_updateCozyRouter() public {
    address _newCozyRouter = makeAddr("newCozyRouter");

    vm.expectEmit(true, true, true, true);
    emit CozyRouterUpdated(_newCozyRouter);
    vm.prank(metadataRegistryOwner);
    metadataRegistry.updateCozyRouter(_newCozyRouter);
    assertEq(metadataRegistry.cozyRouter(), _newCozyRouter);
  }

  function testFuzz_updateCozyRouterUnauthorized(address _who) public {
    vm.assume(_who != metadataRegistryOwner);
    vm.prank(_who);
    vm.expectRevert(MetadataRegistry.Unauthorized.selector);
    metadataRegistry.updateCozyRouter(makeAddr("newCozyRouter"));
  }

  function test_updateOwner() public {
    address _newOwner = makeAddr("newOwner");

    vm.expectEmit(true, true, true, true);
    emit OwnerUpdated(_newOwner);
    vm.prank(metadataRegistryOwner);
    metadataRegistry.updateOwner(_newOwner);
    assertEq(metadataRegistry.owner(), _newOwner);
  }

  function testFuzz_updateOwnerUnauthorized(address _who) public {
    vm.assume(_who != metadataRegistryOwner);
    vm.prank(_who);
    vm.expectRevert(MetadataRegistry.Unauthorized.selector);
    metadataRegistry.updateOwner(makeAddr("newOwner"));
  }
}
