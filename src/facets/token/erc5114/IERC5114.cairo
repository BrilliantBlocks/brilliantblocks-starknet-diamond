%lang starknet

from starkware.cairo.common.uint256 import Uint256

from src.ERC5114.structs import NFT

@contract_interface
namespace IERC5114 {
    // @selector 0x2962ba17806af798afa6eaf4aa8c93a9fb60a3e305045b6eea33435086cae9
    func ownerOf(_token_id: Uint256) -> (nft: NFT) {
    }
}
