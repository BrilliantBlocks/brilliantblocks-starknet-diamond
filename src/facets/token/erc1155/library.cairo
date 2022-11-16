%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal, assert_not_zero
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.uint256 import Uint256, uint256_check, uint256_le
from starkware.starknet.common.syscalls import get_caller_address

from lib.cairo_contracts.src.openzeppelin.security.safemath.library import SafeUint256

from src.ERC1155.structs import TokenBatch
from src.ERC1155.IERC1155 import TransferSingle, TransferBatch, ApprovalForAll

@storage_var
func balances_(_owner: felt, _token_id: Uint256) -> (balance: Uint256) {
}

@storage_var
func operator_approvals_(_owner: felt, _operator: felt) -> (bool: felt) {
}

namespace ERC1155 {
    func balance_of{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _owner: felt, _token_id: Uint256
    ) -> (balance: Uint256) {
        with_attr error_message("ERC1155: ZERO ADDRESS") {
            assert_not_zero(_owner);
        }

        with_attr error_message("ERC1155: INVALID UINT256") {
            uint256_check(_token_id);
        }

        let balance = balances_.read(_owner, _token_id);

        return balance;
    }

    func balance_of_batch{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _owners_len: felt, _owners: felt*, _token_ids_len: felt, _token_ids: Uint256*
    ) -> (balances_len: felt, balances: Uint256*) {
        alloc_locals;

        with_attr error_message("ERC1155: NO OWNERS SPECIFIED") {
            assert_not_zero(_owners_len);
        }

        with_attr error_message("ERC1155: CORRUPT CALLDATA") {
            assert _owners_len = _token_ids_len;
        }

        let (balance_array: Uint256*) = alloc();
        local balance_array_len = _owners_len;
        tempvar current_id = 0;
        populate_balance_of_batch(
            _owners, _token_ids, balance_array, balance_array_len, current_id
        );

        return (balance_array_len, balance_array);
    }

    func populate_balance_of_batch{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _owners: felt*,
        _token_ids: Uint256*,
        _balance_array: Uint256*,
        _balance_array_len: felt,
        _current_id: felt,
    ) {
        alloc_locals;

        if (_current_id == _balance_array_len) {
            return ();
        }

        let (balance) = balance_of(_owners[0], _token_ids[0]);
        assert _balance_array[0] = balance;
        populate_balance_of_batch(
            _owners + 1,
            _token_ids + Uint256.SIZE,
            _balance_array + Uint256.SIZE,
            _balance_array_len,
            _current_id + 1,
        );

        return ();
    }

    func is_approved_for_all{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _owner: felt, _operator: felt
    ) -> (bool: felt) {
        let (approved) = operator_approvals_.read(_owner, _operator);

        return (bool=approved);
    }

    func set_approval_for_all{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _operator: felt, _approved: felt
    ) {
        with_attr error_message("ERC1155: ZERO ADDRESS") {
            assert_not_zero(_operator);
        }

        with_attr error_message("ERC1155: BOOL ERROR") {
            assert _approved * (1 - _approved) = 0;
        }

        let (caller) = get_caller_address();
        with_attr error_message("ERC1155: SELF-APPROVAL") {
            assert_not_equal(caller, _operator);
        }

        operator_approvals_.write(caller, _operator, _approved);
        ApprovalForAll.emit(caller, _operator, _approved);

        return ();
    }

    func safe_transfer_from{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _from: felt, _to: felt, _token_id: Uint256, _amount: Uint256
    ) {
        with_attr error_message("ERC1155: ZERO ADDRESS") {
            assert_not_zero(_from);
            assert_not_zero(_to);
        }
        assert_is_owner_or_approved(_from);
        _transfer_from(_from, _to, _token_id, _amount);

        let (caller) = get_caller_address();
        TransferSingle.emit(caller, _from, _to, _token_id, _amount);

        return ();
    }

    func safe_batch_transfer_from{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _from: felt,
        _to: felt,
        _token_ids_len: felt,
        _token_ids: Uint256*,
        _amounts_len: felt,
        _amounts: Uint256*,
    ) {
        alloc_locals;

        with_attr error_message("ERC1155: ZERO ADDRESS") {
            assert_not_zero(_from);
            assert_not_zero(_to);
        }
        assert_is_owner_or_approved(_from);
        _batch_transfer_from(_from, _to, _token_ids_len, _token_ids, _amounts_len, _amounts);

        let (caller) = get_caller_address();
        TransferBatch.emit(caller, _from, _to, _token_ids_len, _token_ids, _amounts_len, _amounts);

        return ();
    }

    func _transfer_from{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _sender: felt, _recipient: felt, _token_id: Uint256, _amount: Uint256
    ) {
        with_attr error_message("ERC1155: INVALID UINT256") {
            uint256_check(_token_id);
            uint256_check(_amount);
        }

        let (sender_balance) = balances_.read(_sender, _token_id);
        let (sufficient_balance) = uint256_le(_amount, sender_balance);

        with_attr error_message("ERC1155: INSUFFICIENT BALANCE") {
            assert sufficient_balance = TRUE;
        }

        let (new_sender_balance) = SafeUint256.sub_le(sender_balance, _amount);
        balances_.write(_sender, _token_id, new_sender_balance);

        let (recipient_balance) = balances_.read(_recipient, _token_id);
        let (new_recipient_balance) = SafeUint256.add(recipient_balance, _amount);
        balances_.write(_recipient, _token_id, new_recipient_balance);

        return ();
    }

    func _batch_transfer_from{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _from: felt,
        _to: felt,
        _token_ids_len: felt,
        _token_ids: Uint256*,
        _amounts_len: felt,
        _amounts: Uint256*,
    ) {
        with_attr error_message("ERC1155: CORRUPT CALLDATA") {
            assert _token_ids_len = _amounts_len;
        }

        if (_token_ids_len == 0) {
            return ();
        }
        _transfer_from(_from, _to, _token_ids[0], _amounts[0]);

        return _batch_transfer_from(
            _from,
            _to,
            _token_ids_len - 1,
            _token_ids + Uint256.SIZE,
            _amounts_len - 1,
            _amounts + Uint256.SIZE,
        );
    }

    func assert_is_owner_or_approved{
        pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr
    }(_address: felt) {
        let (caller) = get_caller_address();

        if (caller == _address) {
            return ();
        }

        let (operator_is_approved) = operator_approvals_.read(_address, caller);
        with_attr error_message("ERC1155: NOT AUTHORIZED") {
            assert operator_is_approved = TRUE;
        }

        return ();
    }

    func _mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _to: felt, _token_id: Uint256, _amount: Uint256
    ) -> () {
        with_attr error_message("ERC1155: ZERO ADDRESS") {
            assert_not_zero(_to);
        }
        with_attr error_message("ERC1155: INVALID UINT256") {
            uint256_check(_token_id);
            uint256_check(_amount);
        }

        let (balance) = balances_.read(_to, _token_id);
        let (new_balance) = SafeUint256.add(balance, _amount);
        balances_.write(_to, _token_id, new_balance);

        return ();
    }

    func _mint_batch{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _to: felt, _token_batch_len: felt, _token_batch: TokenBatch*
    ) -> () {
        if (_token_batch_len == 0) {
            return ();
        }

        _mint(_to, _token_batch[0].id, _token_batch[0].amount);

        return _mint_batch(_to, _token_batch_len - 1, _token_batch + TokenBatch.SIZE);
    }

    func _burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _from: felt, _token_id: Uint256, _amount: Uint256
    ) {
        with_attr error_message("ERC1155: NOT AUTHORIZED") {
            assert_not_zero(_from);
        }
        with_attr error_message("ERC1155: INVALID UINT256") {
            uint256_check(_token_id);
            uint256_check(_amount);
        }

        let (owner_balance) = balances_.read(_from, _token_id);
        let (sufficient_balance) = uint256_le(_amount, owner_balance);
        with_attr error_message("Owner has not enough funds") {
            assert sufficient_balance = TRUE;
        }
        let (new_owner_balance) = SafeUint256.sub_le(owner_balance, _amount);

        balances_.write(_from, _token_id, new_owner_balance);

        return ();
    }

    func _burn_batch{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        _from: felt,
        _tokens_id_len: felt,
        _tokens_id: Uint256*,
        _amounts_len: felt,
        _amounts: Uint256*,
    ) {
        with_attr error_message("ERC1155: INVALID CALLDATA") {
            assert _tokens_id_len = _amounts_len;
        }

        if (_tokens_id_len == 0) {
            return ();
        }

        _burn(_from, _tokens_id[0], _amounts[0]);

        return _burn_batch(
            _from,
            _tokens_id_len - 1,
            _tokens_id + Uint256.SIZE,
            _amounts_len - 1,
            _amounts + Uint256.SIZE,
        );
    }
}
