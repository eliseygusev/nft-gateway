pragma solidity 0.8.16;

import "../BridgedDuck.sol";
import "lib/ds-test/src/test.sol";
import "lib/forge-std/src/Vm.sol";

interface CheatCodes {
    function prank(address) external;
}

contract NFTTest is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    BridgedDuck nft;

    function setUp() public {
        nft = new BridgedDuck('name', 'token', 'baseUri', address(this));
    }

    function testMint() public {
        address mintTo = address(1);
        nft.mint(mintTo, "duck-123");
        assertEq(nft.ownerOf(0), mintTo);
    }

    function testBurn() public {
        address mintTo = address(10);
        nft.mint(mintTo, "duck-123");
        assertEq(nft.ownerOf(0), mintTo);
        cheats.prank(mintTo);
        nft.approve(mintTo, 0);
        cheats.prank(mintTo);
        nft.sendBack(0, "123");
    }

    function testSecondComing() public {
        address mintTo = address(10);
        nft.mint(mintTo, "duck-123");
        assertEq(nft.ownerOf(0), mintTo);
        cheats.prank(mintTo);
        nft.approve(mintTo, 0);
        cheats.prank(mintTo);
        nft.sendBack(0, "123");
        nft.unlock(mintTo, 0);
        cheats.prank(mintTo);
        nft.approve(mintTo, 0);
        cheats.prank(mintTo);
        nft.sendBack(0, "123");
    }
}

contract FailTestMint is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    BridgedDuck nft;

    function setUp() public {
        nft = new BridgedDuck('name', 'token', 'baseUri', address(10));
    }

    function testRevertMint() public {
        address mintTo = address(1);
        vm.expectRevert("Ownable: caller is not the owner");
        nft.mint(mintTo, "duck-123");
    }
}

contract FailTestBurn is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    BridgedDuck nft;

    function setUp() public {
        nft = new BridgedDuck('name', 'token', 'baseUri', address(this));
    }

    function testRevertBurn() public {
        address mintTo = address(10);
        nft.mint(mintTo, "duck-123");
        vm.expectRevert(NotAuthorized.selector);
        nft.sendBack(0, "123");
    }
}

contract FailTradeWhenLocked is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    BridgedDuck nft;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    function setUp() public {
        nft = new BridgedDuck('name', 'token', 'baseUri', address(this));
    }

    function testRevertTrade() public {
        address mintTo = address(10);
        nft.mint(mintTo, "duck-123");
        cheats.prank(mintTo);
        nft.approve(mintTo, 0);
        cheats.prank(mintTo);
        nft.sendBack(0, "123");
        vm.expectRevert(DuckLocked.selector);
        nft.transferFrom(address(this), address(10), 0);
    }
}
