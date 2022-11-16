%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IERC721Receiver {
    // @selector 0xfa119a8fafc6f1a02deb36fe5efbcc4929ef2021e50cf1cb6d1a780ccd009b
    func onERC721Received(
        _operator: felt, _from: felt, _tokenId: Uint256, data_len: felt, data: felt*
    ) -> (selector: felt) {
    }
}
