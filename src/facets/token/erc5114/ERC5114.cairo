%lang starknet

from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.uint256 import Uint256

from src.constants import FUNCTION_SELECTORS, IERC5114_ID
from src.ERC5114.library import ERC5114
from src.ERC5114.structs import NFT

@view
func ownerOf{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _token_id: Uint256
) -> (nft: NFT) {
    let nft = ERC5114.owner_of(_token_id);

    return (nft);
}

// =====================
// ZKode Facet Functions
// =====================

// @dev Called on facet add
@external
func __constructor__{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _token_id: Uint256, _nft: NFT
) {
    ERC5114.mint(_token_id, _nft);

    return ();
}

// @dev Remove this facet
@external
func __destructor__{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    return ();
}

// @dev This facects public functions
@view
@raw_output
func __public__() -> (retdata_size: felt, retdata: felt*) {
    let (func_selectors) = get_label_location(selectors_start);

    return (retdata_size=1, retdata=cast(func_selectors, felt*));

    selectors_start:
    dw FUNCTION_SELECTORS.ERC5114.ownerOf;
}

@view
@raw_output
func __api__() -> (retdata_size: felt, retdata: felt*) {
    let (func_selectors) = get_label_location(selectors_start);

    return (retdata_size=0, retdata=cast(func_selectors, felt*));

    selectors_start:
    // TODO
}

// @dev Define all supported interfaces of this facet
@view
func __supports_interface__(_interface_id: felt) -> (res: felt) {
    if (_interface_id == IERC5114_ID) {
        return (res=TRUE);
    }

    return (res=FALSE);
}
