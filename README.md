# Code of Ethereum Side of NFT gateway

This is a slightly modified code from the gateway between Alt-L1 and Ethereum Mainnet. 
The gateway is centralized (as it is Ownable), but this can be fixed with the MPC controlling EOA owning that bridge.

This is basically ERC-721 but with a slight twist. 
It was needed to make the NFTs visible on OpenSea even when they are bridged away.
This is needed to maintain constant presence on Mainnet (marketing purposes). 
Also this helps to keep all the trading statistics for bridged NFTs.
So the NFTs are not burned when they are bridged back to their origin but rather they are "locked".
"Locking" means they are not available for trading and will be unlocked when they are bridged to Mainnet again.

There are also tests covering all usecases. Useful commands:
```bash
forge test
forge script script/BridgedDuck.s.sol:DeployDuckScript --rpc-url $RPC_URL  --private-key $PRIVATE_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify -vvvv
```