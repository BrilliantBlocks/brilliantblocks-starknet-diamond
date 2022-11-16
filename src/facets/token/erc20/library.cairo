%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_le
from starkware.cairo.common.uint256 import Uint256, uint256_check, uint256_eq, uint256_not
from starkware.starknet.common.syscalls import get_caller_address

from lib.cairo_contracts.src.openzeppelin.security.safemath.library import SafeUint256

from src.ERC20.IERC20 import Transfer, Approval

@storage_var
func total_supply_() -> (res: Uint256) {
}

@storage_var
func balances_(_owner: felt) -> (balance: Uint256) {
}

@storage_var
func allowances_(_owner: felt, _spender: felt) -> (amount: Uint256) {
}

namespace ERC20 {
    func total_supply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        total_supply: Uint256
    ) {
        let (total_supply: Uint256) = total_supply_.read();

        return (total_supply=total_supply);
    }

    func balance_of{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _owner: felt
    ) -> (balance: Uint256) {
        let (balance: Uint256) = balances_.read(_owner);

        return (balance=balance);
    }

    func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _owner: felt, _spender: felt
    ) -> (amount: Uint256) {
        let (allowance: Uint256) = allowances_.read(_owner, _spender);

        return (amount=allowance);
    }

    func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _recipient: felt, _amount: Uint256
    ) -> (success: felt) {
        let (sender) = get_caller_address();
        _transfer(sender, _recipient, _amount);

        return (success=TRUE);
    }

    func transfer_from{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _sender: felt, _recipient: felt, _amount: Uint256
    ) -> (success: felt) {
        let (caller) = get_caller_address();
        _spend_allowance(_sender, caller, _amount);
        _transfer(_sender, _recipient, _amount);

        return (success=TRUE);
    }

    func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _spender: felt, _amount: Uint256
    ) -> (success: felt) {
        with_attr error_message("ERC20: INVALID UINT256") {
            uint256_check(_amount);
        }

        let (caller) = get_caller_address();
        _approve(caller, _spender, _amount);

        return (success=TRUE);
    }

    func increase_allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _spender: felt, _amount: Uint256
    ) -> (success: felt) {
        with_attr error("ERC20: INVALID UINT256") {
            uint256_check(_amount);
        }

        let (caller) = get_caller_address();
        let (current_allowance) = allowances_.read(caller, _spender);
        let (new_allowance) = SafeUint256.add(current_allowance, _amount);

        _approve(caller, _spender, new_allowance);

        return (success=TRUE);
    }

    func decrease_allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _spender: felt, _amount: Uint256
    ) -> (success: felt) {
        alloc_locals;
        with_attr error_message("ERC20: INVALID UINT256") {
            uint256_check(_amount);
        }

        let (caller) = get_caller_address();
        let (current_allowance) = allowances_.read(caller, _spender);
        let (new_allowance) = SafeUint256.sub_le(current_allowance, _amount);

        _approve(caller, _spender, new_allowance);

        return (success=TRUE);
    }

    //
    // Internal
    //

    func _mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _recipient: felt, _amount: Uint256
    ) -> () {
        with_attr error_message("ERC20: INVALID UINT256") {
            uint256_check(_amount);
        }

        with_attr error_message("ERC20: ZERO ADDRESS") {
            assert_not_zero(_recipient);
        }

        let (total_supply) = total_supply_.read();
        let (new_total_supply) = SafeUint256.add(total_supply, _amount);
        total_supply_.write(new_total_supply);

        let (balance) = balances_.read(_recipient);
        let (new_balance) = SafeUint256.add(balance, _amount);
        balances_.write(_recipient, new_balance);

        Transfer.emit(0, _recipient, _amount);

        return ();
    }

    func _burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _owner: felt, _amount: Uint256
    ) -> () {
        with_attr error_message("ERC20: INVALID UINT256") {
            uint256_check(_amount);
        }

        with_attr error_message("ERC20: ZERO ADDRESS") {
            assert_not_zero(_owner);
        }

        let (balance) = balances_.read(_owner);
        let (new_balance: Uint256) = SafeUint256.sub_le(balance, _amount);

        balances_.write(_owner, new_balance);

        let (total_supply) = total_supply_.read();
        let (new_total_supply) = SafeUint256.sub_le(total_supply, _amount);
        total_supply_.write(new_total_supply);
        Transfer.emit(_owner, 0, _amount);

        return ();
    }

    func _transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _sender: felt, _recipient: felt, _amount: Uint256
    ) -> () {
        with_attr error_message("ERC20: INVALID UINT256") {
            uint256_check(_amount);
        }

        with_attr error_message("ERC20: ZERO ADDRESS") {
            assert_not_zero(_sender);
            assert_not_zero(_recipient);
        }

        let (sender_balance) = balances_.read(_sender);
        with_attr error_message("ERC20: INSUFFICIENT BALANCE") {
            let (new_sender_balance) = SafeUint256.sub_le(sender_balance, _amount);
        }
        balances_.write(_sender, new_sender_balance);

        let (recipient_balance) = balances_.read(_recipient);
        let (new_recipient_balance) = SafeUint256.add(recipient_balance, _amount);
        balances_.write(_recipient, new_recipient_balance);
        Transfer.emit(_sender, _recipient, _amount);

        return ();
    }

    func _approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _owner: felt, _spender: felt, _amount: Uint256
    ) -> () {
        with_attr error_message("ERC20: INVALID UINT256") {
            uint256_check(_amount);
        }

        with_attr error_message("ERC20: ZERO ADDRESS") {
            assert_not_zero(_owner);
            assert_not_zero(_spender);
        }

        allowances_.write(_owner, _spender, _amount);
        Approval.emit(_owner, _spender, _amount);

        return ();
    }

    func _spend_allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _owner: felt, _spender: felt, _amount: Uint256
    ) -> () {
        alloc_locals;

        with_attr error_message("ERC20: INVALID UINT256") {
            uint256_check(_amount);
        }

        let (current_allowance) = allowances_.read(_owner, _spender);
        let (infinite) = uint256_not(Uint256(0, 0));
        let (is_infinite) = uint256_eq(current_allowance, infinite);

        if (is_infinite == FALSE) {
            with_attr error_message("ERC20: INSUFFICIENT ALLOWANCE") {
                let (new_allowance) = SafeUint256.sub_le(current_allowance, _amount);
            }

            _approve(_owner, _spender, new_allowance);

            return ();
        }

        return ();
    }
}

namespace API {
}

namespace Library {
}
