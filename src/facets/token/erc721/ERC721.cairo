%lang starknet

from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal, assert_not_zero
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.registers import get_label_location
from starkware.starknet.common.syscalls import get_caller_address

from src.constants import FUNCTION_SELECTORS, IERC721_ID
from src.ERC721.library import ERC721, ERC721Library

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_owner: felt) -> (
    balance: Uint256
) {
    let balance = ERC721.balance_of(_owner);

    return (balance);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _token_id: Uint256
) -> (owner: felt) {
    let owner = ERC721.owner_of(_token_id);

    return (owner);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _token_id: Uint256
) -> (operator: felt) {
    let operator = ERC721.get_approved(_token_id);

    return (operator);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _owner: felt, _operator: felt
) -> (bool: felt) {
    let is_approved = ERC721.is_approved_for_all(_owner, _operator);

    return (is_approved);
}

@external
func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _to, _token_id: Uint256
) -> () {
    ERC721.approve(_to, _token_id);

    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _operator: felt, _approved: felt
) -> () {
    let (caller) = get_caller_address();
    with_attr error_message("ERC721: ZERO ADDRESS") {
        assert_not_zero(caller * _operator);
    }
    with_attr error_message("ERC721: SELF-APPROVAL") {
        assert_not_equal(caller, _operator);
    }
    ERC721.set_approval_for_all(_operator, _approved);

    return ();
}

@external
func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _from: felt, _to: felt, _token_id: Uint256
) -> () {
    ERC721.transfer_from(_from, _to, _token_id);

    return ();
}

@external
func _transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _from: felt, _to: felt, _token_id: Uint256
) -> () {
    ERC721Library._transfer(_from, _to, _token_id);

    return ();
}

@external
func safeTransferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _from: felt, _to: felt, _token_id: Uint256, data_len: felt, data: felt*
) -> () {
    ERC721.safe_transfer_from(_from, _to, _token_id, data_len, data);

    return ();
}

// @revert INVALID TOKEN ID
// @revert ZERO ADDRESS
// @revert EXISTING TOKEN ID
@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _to: felt, _token_id: Uint256
) -> () {
    ERC721.mint(_to, _token_id);

    return ();
}

// =====================
// ZKode Facet Functions
// =====================

// @dev Called on facet add
@external
func __constructor__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _to: felt, _token_id_len: felt, _token_id: Uint256*
) {
    alloc_locals;

    if (_token_id_len == 0) {
        return ();
    }

    ERC721.mint(_to, _token_id[0]);

    return __constructor__(_to, _token_id_len - 1, _token_id + Uint256.SIZE);
}

// @dev Called on facet remove
@external
func __destructor__() {
    return ();
}

// @dev Exported view and invokable functions of this facet
@view
@raw_output
func __public__() -> (retdata_size: felt, retdata: felt*) {
    let (func_selectors) = get_label_location(selectors_start);

    return (retdata_size=8, retdata=cast(func_selectors, felt*));

    selectors_start:
    dw FUNCTION_SELECTORS.ERC721.approve;
    dw FUNCTION_SELECTORS.ERC721.balanceOf;
    dw FUNCTION_SELECTORS.ERC721.getApproved;
    dw FUNCTION_SELECTORS.ERC721.isApprovedForAll;
    dw FUNCTION_SELECTORS.ERC721.ownerOf;
    dw FUNCTION_SELECTORS.ERC721.safeTransferFrom;
    dw FUNCTION_SELECTORS.ERC721.setApprovalForAll;
    dw FUNCTION_SELECTORS.ERC721.transferFrom;
}

@view
@raw_output
func __api__() -> (retdata_size: felt, retdata: felt*) {
    let (func_selectors) = get_label_location(selectors_start);

    return (retdata_size=0, retdata=cast(func_selectors, felt*));

    selectors_start:
}

// @dev Define all supported interfaces of this facet
@view
func __supports_interface__(_interface_id: felt) -> (res: felt) {
    if (_interface_id == IERC721_ID) {
        return (res=TRUE);
    }

    return (res=FALSE);
}
