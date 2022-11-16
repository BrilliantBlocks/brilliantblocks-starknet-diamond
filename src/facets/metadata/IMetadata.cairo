%lang starknet
from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IERC20Metadata {
    // / @selector 0x4c4fb1ab068f6039d5780c68dd0fa2f8742cceb3426d19667778ca7f3518a9
    func decimals() -> (res: felt) {
    }

    // / @selector 0x361458367e696363fbcc70777d07ebbd2394e89fd0adcaf147faccd1d294d60
    func name() -> (res: felt) {
    }

    // / @selector 0x216b05c387bab9ac31918a3e61672f4618601f3c598a2f3f2710f37053e1ea4
    func symbol() -> (res: felt) {
    }
}

@contract_interface
namespace IERC721Metadata {
    // / @selector 0x361458367e696363fbcc70777d07ebbd2394e89fd0adcaf147faccd1d294d60
    func name() -> (res: felt) {
    }

    // / @selector 0x216b05c387bab9ac31918a3e61672f4618601f3c598a2f3f2710f37053e1ea4
    func symbol() -> (res: felt) {
    }

    // / @selector 0x12a7823b0c6bee58f8c694888f32f862c6584caa8afa0242de046d298ba684d
    func tokenURI(_tokenId: Uint256) -> (tokenURI_len: felt, tokenURI: felt*) {
    }
}

@contract_interface
namespace IERC1155Metadata {
    // / @selector 0x2ee3279dd30231650e0b4a1a3516ab3dc26b6d3dfcb6ef20fb4329cfc1213e1
    func uri(_tokenId: Uint256) -> (tokenURI_len: felt, tokenURI: felt*) {
    }
}

@contract_interface
namespace IERC5114Metadata {
    // / @selector 0x362dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d3de
    func tokenUri(_tokenId: Uint256) -> (tokenUri_len: felt, tokenUri: felt*) {
    }

    // / @selector 0x301d70d6d0526f9060e9cba1cf24f38b94fbbed88395add4575967cdb24ab76
    func collectionUri() -> (collectionUri_len: felt, collectionUri: felt*) {
    }

    // / @selector 0x1ca90dda6287e49240ebea9347c5f16889c3d322c63f56cb9b41049ff8d8d4c
    func metadataFormat() -> (res: felt) {
    }
}
