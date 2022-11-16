%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.registers import get_label_location

from src.constants import FUNCTION_SELECTORS, IDIAMONDCUT_ID
from src.ERC2535.library import Diamond
from src.ERC2535.structs import FacetCut

// @emit DiamondCut
// @param _facetCut Array of added facets
// @param _calldata Array of assembled calldata for all FacetCuts
// @revert NOT AUTHORIZED if not owner of diamond
// @revert INVALID FACET_CUT_ACTION
// @revert OVERFULL CALLDATA
@external
func diamondCut{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(_facetCut_len: felt, _facetCut: FacetCut*, _calldata_len: felt, _calldata: felt*) -> () {
    alloc_locals;
    Diamond.Assert.only_owner();
    with_attr error_message("PUBLIC diamondCut {_facetCut_len} {_calldata_len}") {
        Diamond._diamondCut(_facetCut_len, _facetCut, _calldata_len, _calldata);
    }
    return ();
}

@external
func _diamondCut{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(_facetCut_len: felt, _facetCut: FacetCut*, _calldata_len: felt, _calldata: felt*) -> () {
    alloc_locals;
    Diamond._diamondCut(_facetCut_len, _facetCut, _calldata_len, _calldata);
    return ();
}

// @dev Initialize this facet
@external
func __constructor__(_x_len: felt, _x: felt*) -> () {
    return ();
}

// @dev Remove this facet
@external
func __destructor__() -> () {
    return ();
}

// @dev Exported view and invokable functions of this facet
@view
@raw_output
func __get_function_selectors__() -> (retdata_size: felt, retdata: felt*) {
    let (func_selectors) = get_label_location(selectors_start);
    return (retdata_size=1, retdata=cast(func_selectors, felt*));

    selectors_start:
    dw FUNCTION_SELECTORS.DIAMONDCUT.diamondCut;
}

// @dev Define all supported interfaces of this facet
@view
func __supports_interface__(_interface_id: felt) -> (res: felt) {
    if (_interface_id == IDIAMONDCUT_ID) {
        return (res=TRUE);
    }
    return (res=FALSE);
}
