%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.registers import get_label_location

from src.constants import FUNCTION_SELECTORS, IERC1155_ID
from src.ERC1155.structs import TokenBatch
from src.ERC1155.library import ERC1155

@view
func balanceOf{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _owner: felt, _token_id: Uint256
) -> (balance: Uint256) {
    let balance = ERC1155.balance_of(_owner, _token_id);

    return (balance);
}

@view
func balanceOfBatch{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _owners_len: felt, _owners: felt*, _token_ids_len: felt, _token_ids: Uint256*
) -> (balances_len: felt, balances: Uint256*) {
    let (balances_len, balances) = ERC1155.balance_of_batch(
        _owners_len, _owners, _token_ids_len, _token_ids
    );

    return (balances_len, balances);
}

@view
func isApprovedForAll{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _owner: felt, _operator: felt
) -> (bool: felt) {
    let (is_approved) = ERC1155.is_approved_for_all(_owner, _operator);

    return (bool=is_approved);
}

@external
func setApprovalForAll{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _operator: felt, _approved: felt
) -> () {
    ERC1155.set_approval_for_all(_operator, _approved);

    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, _to: felt, _token_id: Uint256, _amount: Uint256
) -> () {
    ERC1155.safe_transfer_from(_from, _to, _token_id, _amount);

    return ();
}

@external
func safeBatchTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt,
    _to: felt,
    _token_ids_len: felt,
    _token_ids: Uint256*,
    _amounts_len: felt,
    _amounts: Uint256*,
) -> () {
    ERC1155.safe_batch_transfer_from(
        _from, _to, _token_ids_len, _token_ids, _amounts_len, _amounts
    );

    return ();
}

// =====================
// ZKode Facet Functions
// =====================

// @dev Called on facet add
@external
func __constructor__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _to: felt, _token_batch_len: felt, _token_batch: TokenBatch*
) -> () {
    ERC1155._mint_batch(_to, _token_batch_len, _token_batch);

    return ();
}

// @dev Called on facet remove
@external
func __destructor__() -> () {
    return ();
}

// @dev This facects public functions
@view
@raw_output
func __public__() -> (retdata_size: felt, retdata: felt*) {
    let (func_selectors) = get_label_location(selectors_start);

    return (retdata_size=6, retdata=cast(func_selectors, felt*));

    selectors_start:
    dw FUNCTION_SELECTORS.ERC1155.balanceOf;
    dw FUNCTION_SELECTORS.ERC1155.balanceOfBatch;
    dw FUNCTION_SELECTORS.ERC1155.isApprovedForAll;
    dw FUNCTION_SELECTORS.ERC1155.safeBatchTransferFrom;
    dw FUNCTION_SELECTORS.ERC1155.safeTransferFrom;
    dw FUNCTION_SELECTORS.ERC1155.setApprovalForAll;
}

@view
@raw_output
func __api__() -> (retdata_size: felt, retdata: felt*) {
    let (func_selectors) = get_label_location(selectors_start);

    return (retdata_size=0, retdata=cast(func_selectors, felt*));

    selectors_start:
    // TODO
}

// @dev This facets supported interfaces
@view
func __supports_interface__(_interface_id: felt) -> (res: felt) {
    if (_interface_id == IERC1155_ID) {
        return (res=TRUE);
    }

    return (res=FALSE);
}
