%lang starknet

from starkware.cairo.common.uint256 import Uint256

// @selector 0x99cd8bde557814842a3121e8ddfd433a539b8c9f14bf31ebf108d12e6196e9
@event
func Transfer(from_: felt, to: felt, amount: Uint256) {
}

// @selector 0x134692b230b9e1ffa39098904722134159652b09c5bc41d88d6698779d228ff
@event
func Approval(owner: felt, spender: felt, amount: Uint256) {
}

@contract_interface
namespace IERC20 {
    // @selector 0x80aa9fdbfaf9615e4afc7f5f722e265daca5ccc655360fa5ccacf9c267936d
    func totalSupply() -> (res: Uint256) {
    }

    // @selector 0x2e4263afad30923c891518314c3c95dbe830a16874e8abc5777a9a20b54c76e
    func balanceOf(_owner: felt) -> (balance: Uint256) {
    }

    // @selector 0x1e888a1026b19c8c0b57c72d63ed1737106aa10034105b980ba117bd0c29fe1
    func allowance(_owner: felt, _spender: felt) -> (amount: Uint256) {
    }

    // @selector 0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e
    func transfer(_recipient: felt, _amount: Uint256) -> (success: felt) {
    }

    // @selector 0x41b033f4a31df8067c24d1e9b550a2ce75fd4a29e1147af9752174f0e6cb20
    func transferFrom(_sender: felt, _recipient: felt, _amount: Uint256) -> (success: felt) {
    }

    // @selector 0x219209e083275171774dab1df80982e9df2096516f06319c5c6d71ae0a8480c
    func approve(_spender: felt, _amount: Uint256) -> (success: felt) {
    }
}
