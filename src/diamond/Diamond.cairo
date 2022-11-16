%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.starknet.common.syscalls import library_call

from src.constants import FUNCTION_SELECTORS, IERC165_ID, IDIAMONDLOUPE_ID
from src.ERC2535.library import Diamond

@storage_var
func bfr_facet_() -> (res: felt) {
}

// @param _root: Address of TCF
// @param _facet_key Bitmap encoding included facets
// @param _init_facet Facet required for init of a root diamond
// @param _bfr_facet Registry facet
@constructor
func constructor{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(_root: felt, _facet_key: felt, _init_facet: felt, _bfr_facet: felt) {
    Diamond._set_facet_key_(_facet_key);
    Diamond._set_root_(_root);
    Diamond._set_init_root_(_init_facet);
    bfr_facet_.write(_bfr_facet);

    return ();
}

// @revert UNKNOWN FUNCTION if selector not found in any facet
@external
@raw_input
@raw_output
func __default__{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(selector: felt, calldata_size: felt, calldata: felt*) -> (retdata_size: felt, retdata: felt*) {
    alloc_locals;

    local facet: felt;
    local retdata_size: felt;
    local retdata: felt*;

    // TODO
    // if root = self BFR ask class hash, else call root
    if (selector == FUNCTION_SELECTORS.IBFR.resolveKey) {
        let (bfr) = bfr_facet_.read();
        // library call to BFR facet
        let (retdata_size: felt, retdata: felt*) = library_call(
            class_hash=bfr,
            function_selector=selector,
            calldata_size=calldata_size,
            calldata=calldata,
        );
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar bitwise_ptr = bitwise_ptr;
        tempvar range_check_ptr = range_check_ptr;
    } else {
        let (facet: felt) = facetAddress(selector);
        let (retdata_size: felt, retdata: felt*) = library_call(
            class_hash=facet,
            function_selector=selector,
            calldata_size=calldata_size,
            calldata=calldata,
        );
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar bitwise_ptr = bitwise_ptr;
        tempvar range_check_ptr = range_check_ptr;
    }

    return (retdata_size, retdata);
}

// @return Array of included class hashes
@view
func facetAddresses{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}() -> (res_len: felt, res: felt*) {
    let (facets_len, facets) = Diamond._facetAddresses();

    return (facets_len, facets);
}

// @dev Resolve alias as if they were the actual function
// @revert UNKNOWN FUNCTION if selector not found in any facet
// @return Class hash implementing _functionSelector
@view
func facetAddress{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(_func_sel: felt) -> (res: felt) {
    let (class_hash) = Diamond._facetAddress(_func_sel);

    return (res=class_hash);
}

// @revert FACET NOT FOUND
// @return Array of selectors implemented in a facet
@view
func facetFunctionSelectors{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(_facet: felt) -> (res_len: felt, res: felt*) {
    Diamond.Assert.facet_exists(_facet);

    let (func_sel_len, func_sel) = Diamond._facetFunctionSelectors(_facet);

    return (func_sel_len, func_sel);
}

// @dev Same as facetAddresses()
// @return Array of included class hashes
@view
func facets{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}() -> (res_len: felt, res: felt*) {
    return facetAddresses();
}

// @dev Calls all facets for their supported interfaces
@view
func supportsInterface{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(_interface_id: felt) -> (res: felt) {
    alloc_locals;

    if (_interface_id == IERC165_ID) {
        return (res=TRUE);
    }

    if (_interface_id == IDIAMONDLOUPE_ID) {
        return (res=TRUE);
    }

    let (facets_len, facets) = facetAddresses();

    return Diamond._supportsInterface(_interface_id, facets_len, facets);
}

// @dev Aspect requires this function for token type detection
// @notice The respective facet must be included at deploy time
// @return Class hash of token type. Return 0 if no token is included
@view
func getImplementation{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}() -> (res: felt) {
    let (facets_len, facets) = facetAddresses();
    let token_facet = Diamond._find_token_facet(facets_len, facets);

    return (res=token_facet);
}

// @return Address of root factory
@view
func getRoot{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let root = Diamond._get_root_();

    return (res=root);
}
