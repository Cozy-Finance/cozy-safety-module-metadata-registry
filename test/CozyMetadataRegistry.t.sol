// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import "forge-std/Test.sol";
import {MetadataRegistry} from "../src/MetadataRegistry.sol";
import {ISafetyModule} from "../src/interfaces/ISafetyModule.sol";
import {ICozySafetyModuleManager} from "../src/interfaces/ICozySafetyModuleManager.sol";
import {MockManager} from "./MockCozySafetyModuleManager.sol";

contract MetadataRegistryTestSetup is Test {
  MetadataRegistry metadataRegistry;

  address cozyRouter;
  address cozySafetyModuleManager;
  address localOwner;
  address metadataRegistryOwner;

  address controllerA;
  address controllerB;

  address safetyModuleA;
  address safetyModuleB;
  address safetyModuleAOwner;
  address safetyModuleBOwner;

  event CozyRouterUpdated(address indexed cozyRouter);
  event CozySafetyModuleManagerUpdated(address indexed cozySafetyModuleManager);
  event OwnerUpdated(address indexed owner);
  event SafetyModuleMetadataUpdated(address indexed safetyModule, MetadataRegistry.Metadata metadata);
  event ControllerMetadataUpdated(address indexed controller, MetadataRegistry.Metadata metadata);

  function setUp() public {
    cozyRouter = makeAddr("cozyRouter");
    localOwner = makeAddr("localOwner");
    metadataRegistryOwner = makeAddr("metadataRegistryOwner");

    controllerA = makeAddr("controllerA");
    controllerB = makeAddr("controllerB");

    MockManager mockManager_ = new MockManager();
    cozySafetyModuleManager = address(mockManager_);

    // Mock manager responses.
    mockManager_.setControllerRegistry(controllerA, ISafetyModule(safetyModuleA));
    mockManager_.setControllerRegistry(controllerB, ISafetyModule(safetyModuleB));
    vm.mockCall(safetyModuleA, abi.encodeWithSelector(ISafetyModule.owner.selector), abi.encode(safetyModuleAOwner));
    vm.mockCall(safetyModuleB, abi.encodeWithSelector(ISafetyModule.owner.selector), abi.encode(safetyModuleBOwner));

    // Deploy metadata registry.
    metadataRegistry = new MetadataRegistry(metadataRegistryOwner, cozyRouter, cozySafetyModuleManager);
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
      "$category: Category",
      1
    );
  }

  function testFuzz_UpdateControllerMetadata(
    string memory _name,
    string memory _description,
    string memory _logo,
    string memory _extraData,
    uint8 _rand
  ) public {
    MetadataRegistry.Metadata[] memory _metadata = new MetadataRegistry.Metadata[](1);
    _metadata[0] = MetadataRegistry.Metadata(_name, _description, _logo, _extraData);

    address[] memory _controllers = new address[](1);
    address _selectedController = (_rand % 2 == 0) ? controllerA : controllerB;
    address _selectedSafetyModuleOwner = (_rand % 2 == 0) ? safetyModuleAOwner : safetyModuleBOwner;
    _controllers[0] = _selectedController;

    vm.expectEmit(true, true, true, true);
    emit ControllerMetadataUpdated(_selectedController, _metadata[0]);
    vm.prank(_selectedSafetyModuleOwner);
    metadataRegistry.updateControllerMetadata(_controllers, _metadata);

    vm.expectEmit(true, true, true, true);
    emit ControllerMetadataUpdated(address(_selectedController), _metadata[0]);
    vm.prank(_selectedSafetyModuleOwner);
    metadataRegistry.updateControllerMetadata(_controllers, _metadata);
  }

  function testFuzz_UpdateControllerMetadataUnauthorized(
    address _who,
    string memory _name,
    string memory _description,
    string memory _logo,
    string memory _extraData
  ) public {
    vm.assume(_who != safetyModuleAOwner);
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

  function test_updateCozySafetyModuleManager() public {
    address _newCozySafetyModuleManager = makeAddr("newCozySafetyModuleManager");

    vm.expectEmit(true, true, true, true);
    emit CozySafetyModuleManagerUpdated(_newCozySafetyModuleManager);
    vm.prank(metadataRegistryOwner);
    metadataRegistry.updateCozySafetyModuleManager(_newCozySafetyModuleManager);
    assertEq(metadataRegistry.cozySafetyModuleManager(), _newCozySafetyModuleManager);
  }

  function testFuzz_updateCozySafetyModuleManagerUnauthorized(address _who) public {
    vm.assume(_who != metadataRegistryOwner);
    vm.prank(_who);
    vm.expectRevert(MetadataRegistry.Unauthorized.selector);
    metadataRegistry.updateCozySafetyModuleManager(makeAddr("newCozySafetyModuleManager"));
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
