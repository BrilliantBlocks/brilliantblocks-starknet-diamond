%lang starknet

// @selector 0x3c27a8b448fe684611cd3c9b512daa99c6543934865e0e59b40602bd8db4ea8
@event
func DiamondCut(_facet_cut: FacetCut, _calldata_len: felt, _calldata: felt*) {
}

@contract_interface
namespace IDiamondCut {
    // @selector 0xf3d1ef016a3319b5c905f7ed8ae0708b96b732c565c6058e6a4f0291032848
    func diamondCut(
        _facet_cut_len: felt, _facet_cut: FacetCut*, _calldata_len: felt, _calldata: felt*
    ) -> () {
    }
}
