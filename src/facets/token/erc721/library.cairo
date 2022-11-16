%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal, assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.starknet.common.syscalls import get_caller_address

from lib.cairo_contracts.src.openzeppelin.security.safemath.library import SafeUint256

from src.constants import IERC721_RECEIVER_ID, IACCOUNT_ID
from src.interfaces.IERC165 import IERC165
from src.ERC721.IERC721 import Approval, ApprovalForAll, Transfer
from src.ERC721.IERC721Receiver import IERC721Receiver

@storage_var
func owners_(_token_id: Uint256) -> (res: felt) {
}

@storage_var
func balances_(_owner: felt) -> (res: Uint256) {
}

@storage_var
func token_approvals_(_token_id: Uint256) -> (res: felt) {
}

@storage_var
func operator_approvals_(_owner: felt, _operator: felt) -> (res: felt) {
}

namespace ERC721 {
    func balance_of{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _owner: felt
    ) -> (balance: Uint256) {
        ERC721Library._assert_address_not_zero(_owner);

        let (balance: Uint256) = balances_.read(_owner);

        return (balance=balance);
    }

    func owner_of{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _token_id: Uint256
    ) -> (owner: felt) {
        ERC721Library._assert_valid(_token_id);
        ERC721Library._assert_minted(_token_id);

        let (owner: felt) = owners_.read(_token_id);

        return (owner=owner);
    }

    func get_approved{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _token_id: Uint256
    ) -> (operator: felt) {
        ERC721Library._assert_valid(_token_id);
        ERC721Library._assert_minted(_token_id);

        let (operator: felt) = token_approvals_.read(_token_id);

        return (operator=operator);
    }

    func is_approved_for_all{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _owner: felt, _operator: felt
    ) -> (bool: felt) {
        ERC721Library._assert_address_not_zero(_owner);
        ERC721Library._assert_address_not_zero(_operator);

        let (is_approved) = operator_approvals_.read(_owner, _operator);

        return (bool=is_approved);
    }

    func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _to: felt, _token_id: Uint256
    ) -> () {
        alloc_locals;

        ERC721Library._assert_valid(_token_id);
        ERC721Library._assert_is_owner_or_operator(_token_id);
        ERC721Library._assert_owner_is_not_receiver(_to, _token_id);
        ERC721Library._assert_address_not_zero(_to);

        ERC721Library._approve(_to, _token_id);

        return ();
    }

    func set_approval_for_all{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _operator: felt, _approved: felt
    ) -> () {
        alloc_locals;

        ERC721Library._assert_caller_is_not_operator(_operator);
        ERC721Library._assert_is_boolean(_approved);

        ERC721Library._setApprovalForAll(_operator, _approved);

        return ();
    }

    func safe_transfer_from{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _from: felt, _to: felt, _token_id: Uint256, data_len: felt, data: felt*
    ) -> () {
        transfer_from(_from, _to, _token_id);

        ERC721Library._assert_token_received(_from, _to, _token_id, data_len, data);
        return ();
    }

    func transfer_from{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _from: felt, _to: felt, _token_id: Uint256
    ) -> () {
        alloc_locals;

        ERC721Library._assert_valid(_token_id);
        ERC721Library._assert_minted(_token_id);
        ERC721Library._assert_is_owner_or_operator(_token_id);
        ERC721Library._assert_valid_from_address(_from, _token_id);
        ERC721Library._assert_address_not_zero(_to);

        ERC721Library._transfer(_from, _to, _token_id);

        return ();
    }

    func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _to: felt, _token_id: Uint256
    ) -> () {
        ERC721Library._assert_valid(_token_id);
        ERC721Library._assert_address_not_zero(_to);
        ERC721Library._assert_not_minted(_token_id);

        ERC721Library._mint(_to, _token_id);

        return ();
    }

    func burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_token_id: Uint256) {
        alloc_locals;

        ERC721Library._assert_valid(_token_id);
        ERC721Library._assert_minted(_token_id);
        ERC721Library._assert_only_owner(_token_id);

        let (caller) = get_caller_address();
        ERC721Library._transfer(caller, 0, _token_id);

        return ();
    }

    // @dev Used for token based access control
    func _assertOnlyOwner{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _token_id: Uint256
    ) {
        ERC721Library._assert_only_owner(_token_id);

        return ();
    }
}

namespace ERC721Library {
    // @dev A tokenId is valid if it conforms to Uint256 and is not 0
    func _assert_valid{range_check_ptr}(_token_id: Uint256) {
        with_attr error_message("INVALID TOKEN ID") {
            uint256_check(_token_id);
            assert_not_zero(_token_id.low + _token_id.high);
        }
        return ();
    }

    func _assert_valid_from_address{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(_from: felt, _token_id: Uint256) {
        let (owner) = owners_.read(_token_id);
        with_attr error_message("INVALID FROM") {
            assert owner = _from;
        }
        return ();
    }

    func _assert_is_boolean(_x: felt) {
        with_attr error_message("BOOL ERROR") {
            assert (1 - _x) * _x = 0;
        }
        return ();
    }

    func _assert_address_not_zero{range_check_ptr}(_address: felt) {
        with_attr error_message("ZERO ADDRESS") {
            assert_not_zero(_address);
        }
        return ();
    }

    func _assert_minted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _token_id: Uint256
    ) {
        let exists = _exists(_token_id);
        with_attr error_message("UNKNOWN TOKEN ID") {
            assert exists = TRUE;
        }
        return ();
    }

    func _assert_not_minted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _token_id: Uint256
    ) {
        let exists = _exists(_token_id);
        with_attr error_message("EXISTING TOKEN ID") {
            assert exists = FALSE;
        }
        return ();
    }

    func _assert_is_owner_or_operator{
        pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr
    }(_token_id: Uint256) {
        alloc_locals;
        let (local caller: felt) = get_caller_address();
        let (local owner: felt) = owners_.read(_token_id);
        if (owner == caller) {
            return ();
        }
        let (approved_address) = token_approvals_.read(_token_id);
        if (approved_address == caller) {
            return ();
        }
        let (is_operator) = operator_approvals_.read(owner, caller);
        if (is_operator == TRUE) {
            return ();
        }
        with_attr error_message("UNAUTHORIZED: caller = {caller} | owner = {owner}") {
            assert 0 = 1;
        }
        return ();
    }

    func _assert_only_owner{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _token_id: Uint256
    ) {
        let (owner) = owners_.read(_token_id);
        let (caller) = get_caller_address();
        with_attr error_message("UNAUTHORIZED") {
            assert owner = caller;
        }
        return ();
    }

    func _assert_owner_is_not_receiver{
        pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr
    }(_to: felt, _token_id: Uint256) {
        let (owner) = owners_.read(_token_id);
        with_attr error_message("DISABLED FOR OWNER") {
            assert_not_equal(owner, _to);
        }
        return ();
    }

    func _assert_caller_is_not_operator{
        pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr
    }(_operator) {
        let (caller) = get_caller_address();
        with_attr error_message("DISABLED FOR OPERATOR") {
            assert_not_equal(caller, _operator);
        }
        return ();
    }

    func _assert_no_self_approval{syscall_ptr: felt*}(_caller: felt, _operator: felt) {
        with_attr error_message("SELF APPROVAL") {
            assert_not_equal(_caller, _operator);
        }
        return ();
    }

    func _assert_token_received{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _from: felt, _to: felt, _token_id: Uint256, data_len: felt, data: felt*
    ) {
        let success = _check_onERC721Received(_from, _to, _token_id, data_len, data);
        with_attr error_message("NOT RECEIVED") {
            assert success = TRUE;
        }
        return ();
    }

    func _exists{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _token_id: Uint256
    ) -> felt {
        let (res) = owners_.read(_token_id);
        if (res == 0) {
            return FALSE;
        } else {
            return TRUE;
        }
    }

    func _approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _to: felt, _token_id: Uint256
    ) -> () {
        let (owner) = owners_.read(_token_id);
        token_approvals_.write(_token_id, _to);
        Approval.emit(owner, _to, _token_id);
        return ();
    }

    func _setApprovalForAll{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _operator: felt, _approved: felt
    ) -> () {
        let (caller) = get_caller_address();
        _assert_address_not_zero(caller);
        _assert_address_not_zero(_operator);
        _assert_is_boolean(_approved);
        _assert_no_self_approval(caller, _operator);
        operator_approvals_.write(caller, _operator, _approved);
        ApprovalForAll.emit(caller, _operator, _approved);
        return ();
    }

    func _transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _from: felt, _to: felt, _token_id: Uint256
    ) -> () {
        // Clear approvals
        _approve(0, _token_id);

        // Decrease owner balance
        let (owner_balance) = balances_.read(_from);
        let (new_balance: Uint256) = SafeUint256.sub_le(owner_balance, Uint256(1, 0));
        balances_.write(_from, new_balance);

        // Increase receiver balance
        let (receiver_balance) = balances_.read(_to);
        let (new_balance: Uint256) = SafeUint256.add(receiver_balance, Uint256(1, 0));
        balances_.write(_to, new_balance);

        // Update token_id owner
        owners_.write(_token_id, _to);
        Transfer.emit(_from, _to, _token_id);
        return ();
    }

    func _check_onERC721Received{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _from: felt, _to: felt, _token_id: Uint256, data_len: felt, data: felt*
    ) -> felt {
        let (caller) = get_caller_address();
        let (supports_erc721) = IERC165.supportsInterface(_to, IERC721_RECEIVER_ID);
        if (supports_erc721 == TRUE) {
            let (selector) = IERC721Receiver.onERC721Received(
                _to, caller, _from, _token_id, data_len, data
            );
            with_attr error_message("RECEIVER ERROR") {
                assert selector = IERC721_RECEIVER_ID;
            }
            return TRUE;
        }

        let (is_account) = IERC165.supportsInterface(_to, IACCOUNT_ID);
        return is_account;
    }

    func _mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _to: felt, _token_id: Uint256
    ) -> () {
        let (balance) = balances_.read(_to);
        let (new_balance) = SafeUint256.add(balance, Uint256(1, 0));
        balances_.write(_to, new_balance);
        owners_.write(_token_id, _to);
        Transfer.emit(0, _to, _token_id);
        return ();
    }
}
