%lang starknet

from starkware.cairo.common.uint256 import Uint256

// @selector 0x134692b230b9e1ffa39098904722134159652b09c5bc41d88d6698779d228ff
@event
func Approval(_owner: felt, _approved: felt, _tokenId: Uint256) {
}

// @selector 0x6ad9ed7b6318f1bcffefe19df9aeb40d22c36bed567e1925a5ccde0536edd
@event
func ApprovalForAll(_owner: felt, _operator: felt, _approved: felt) {
}

// @selector 0x99cd8bde557814842a3121e8ddfd433a539b8c9f14bf31ebf108d12e6196e9
@event
func Transfer(_from: felt, _to: felt, _tokenId: Uint256) {
}

@contract_interface
namespace IERC721 {
    // @selector 0x2e4263afad30923c891518314c3c95dbe830a16874e8abc5777a9a20b54c76e
    func balanceOf(_owner: felt) -> (res: Uint256) {
    }

    // @selector 0x2962ba17806af798afa6eaf4aa8c93a9fb60a3e305045b6eea33435086cae9
    func ownerOf(_tokenId: Uint256) -> (res: felt) {
    }

    // @selector 0xb180e2fe9f14914416216da76338ac0beb980443725c802af615f8431fdb1e
    func getApproved(_tokenId: Uint256) -> (res: felt) {
    }

    // @selector 0x21cdf9aedfed41bc4485ae779fda471feca12075d9127a0fc70ac6b3b3d9c30
    func isApprovedForAll(_owner: felt, _operator: felt) -> (res: felt) {
    }

    // @selector 0x219209e083275171774dab1df80982e9df2096516f06319c5c6d71ae0a8480c
    func approve(_to: felt, _tokenId: Uint256) -> () {
    }

    // @selector 0x2d4c8ea4c8fb9f571d1f6f9b7692fff8e5ceaf73b1df98e7da8c1109b39ae9a
    func setApprovalForAll(_operator: felt, _approved: felt) -> () {
    }

    // @selector 0x41b033f4a31df8067c24d1e9b550a2ce75fd4a29e1147af9752174f0e6cb20
    func transferFrom(_from: felt, _to: felt, _tokenId: Uint256) -> () {
    }

    // @selector 0x19d59d013d4aa1a8b1ce4c8299086f070733b453c02d0dc46e735edc04d6444
    func safeTransferFrom(
        _from: felt, _to: felt, _tokenId: Uint256, data_len: felt, data: felt*
    ) -> () {
    }
}
