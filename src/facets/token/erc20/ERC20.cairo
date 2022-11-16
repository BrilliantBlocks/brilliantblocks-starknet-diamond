%lang starknet

from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.uint256 import Uint256

from src.constants import FUNCTION_SELECTORS, IERC20_ID
from src.ERC20.library import ERC20

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    total_supply: Uint256
) {
    let total_supply = ERC20.total_supply();

    return (total_supply);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_owner: felt) -> (
    balance: Uint256
) {
    let balance = ERC20.balance_of(_owner);

    return (balance);
}

@view
func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _owner: felt, _spender: felt
) -> (amount: Uint256) {
    let allowance = ERC20.allowance(_owner, _spender);

    return (allowance);
}

@external
func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _recipient: felt, _amount: Uint256
) -> (success: felt) {
    let success = ERC20.transfer(_recipient, _amount);

    return (success);
}

@external
func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _sender: felt, _recipient: felt, _amount: Uint256
) -> (success: felt) {
    let success = ERC20.transfer_from(_sender, _recipient, _amount);

    return (success);
}

@external
func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _spender: felt, _amount: Uint256
) -> (success: felt) {
    let success = ERC20.approve(_spender, _amount);

    return (success);
}

@external
func increaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _spender: felt, _amount: Uint256
) -> (success: felt) {
    let success = ERC20.increase_allowance(_spender, _amount);

    return (success);
}

@external
func decreaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _spender: felt, _amount: Uint256
) -> (success: felt) {
    let success = ERC20.decrease_allowance(_spender, _amount);

    return (success);
}

// =====================
// ZKode Facet Functions
// =====================

// @dev Called on facet add
@external
func __constructor__{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _recipient: felt, _supply: Uint256
) -> () {
    ERC20._mint(_recipient, _supply);

    return ();
}

// @dev Called on facet remove
@external
func __destructor__() -> () {
    return ();
}

// @dev Exported view and invokable functions of this facet
@view
@raw_output
func __public__() -> (retdata_size: felt, retdata: felt*) {
    let (func_selectors) = get_label_location(selectors_start);

    return (retdata_size=8, retdata=cast(func_selectors, felt*));

    selectors_start:
    dw FUNCTION_SELECTORS.ERC20.allowance;
    dw FUNCTION_SELECTORS.ERC20.approve;
    dw FUNCTION_SELECTORS.ERC20.balanceOf;
    dw FUNCTION_SELECTORS.ERC20.decreaseAllowance;
    dw FUNCTION_SELECTORS.ERC20.increaseAllowance;
    dw FUNCTION_SELECTORS.ERC20.totalSupply;
    dw FUNCTION_SELECTORS.ERC20.transfer;
    dw FUNCTION_SELECTORS.ERC20.transferFrom;
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
    if (_interface_id == IERC20_ID) {
        return (res=TRUE);
    }

    return (res=FALSE);
}
