%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_check,
    uint256_eq,
    uint256_unsigned_div_rem,
)
from starkware.cairo.common.pow import pow

@storage_var
func decimals_() -> (res: felt) {
}

@storage_var
func name_() -> (res: felt) {
}

@storage_var
func symbol_() -> (res: felt) {
}

// / @dev This storage variable contains an array structure
// / @dev Sequence of nonzero elements starting from zero
// / @dev token_uri_prefix_(i) = 0 marks the end of the array
@storage_var
func token_uri_prefix_(i: felt) -> (res: felt) {
}

// / @dev Optinally include the token id as infix
@storage_var
func token_uri_id_infix_() -> (bool: felt) {
}

// / @dev This storage variable contains an array structure
// / @dev Sequence of nonzero elements starting from zero
// / @dev token_uri_suffix_(i) = 0 marks the end of the array
@storage_var
func token_uri_suffix_(i: felt) -> (res: felt) {
}

@storage_var
func metadata_format_() -> (res: felt) {
}

// / @dev This storage variable contains an array structure
// / @dev Sequence of nonzero elements starting from zero
// / @dev collection_uri_(i) = 0 marks the end of the array
@storage_var
func collection_uri_(i: felt) -> (res: felt) {
}

namespace UniversalMetadata {
    func _get_collection_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> (collection_uri_len: felt, collection_uri: felt*) {
        let (collection_uri_len, collection_uri) = Library._get_collection_uri_();
        return (collection_uri_len, collection_uri);
    }

    func _set_collection_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _collection_uri_len: felt, _collection_uri: felt*
    ) {
        Library._set_collection_uri_(_collection_uri_len, _collection_uri);
        return ();
    }

    func _get_decimals_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
        let (decimals) = decimals_.read();
        return decimals;
    }

    func _set_decimals_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _decimals: felt
    ) {
        decimals_.write(_decimals);
        return ();
    }

    func _get_name_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
        let (name) = name_.read();
        return name;
    }

    func _set_name_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_name: felt) {
        name_.write(_name);
        return ();
    }

    func _get_symbol_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
        let (symbol) = symbol_.read();
        return symbol;
    }

    func _set_symbol_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _symbol: felt
    ) {
        symbol_.write(_symbol);
        return ();
    }

    func _get_metadata_format_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> felt {
        let (metadata_format) = metadata_format_.read();
        return metadata_format;
    }

    func _set_metadata_format_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _metadata_format: felt
    ) {
        metadata_format_.write(_metadata_format);
        return ();
    }

    // / @return Concatenation of prefix, infix and suffix
    func _get_token_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _tokenId: Uint256
    ) -> (token_uri_len: felt, token_uri: felt*) {
        alloc_locals;
        let (prefix_uri_len, prefix_uri) = Library._get_prefix_uri_();
        let (infix_uri_len, infix_uri) = Library._get_infix_uri_(_tokenId);
        let (suffix_uri_len, suffix_uri) = Library._get_suffix_uri_();
        let (token_uri_len, token_uri) = Library._concatenate_token_uri(
            prefix_uri_len, prefix_uri, infix_uri_len, infix_uri, suffix_uri_len, suffix_uri
        );
        return (token_uri_len, token_uri);
    }

    func _set_token_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _uri_prefix_len: felt,
        _uri_prefix: felt*,
        _has_token_id_infix: felt,
        _uri_suffix_len: felt,
        _uri_suffix: felt*,
    ) {
        Library._set_token_uri_prefix_(_uri_prefix_len, _uri_prefix);
        Library._set_token_uri_id_infix_(_has_token_id_infix);
        Library._set_suffix_uri_(_uri_suffix_len, _uri_suffix);
        return ();
    }
}

namespace Library {
    func _concatenate_token_uri{range_check_ptr}(
        _p_len: felt, _p: felt*, _i_len: felt, _i: felt*, _s_len: felt, _s: felt*
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        let (res) = alloc();
        memcpy(res, _p, _p_len);
        memcpy(res + _p_len, _i, _i_len);
        memcpy(res + _p_len + _i_len, _s, _s_len);
        return (_p_len + _i_len + _s_len, res);
    }

    func _set_token_uri_prefix_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_uri_len: felt, token_uri: felt*
    ) -> () {
        alloc_locals;
        if (token_uri_len == 0) {
            return ();
        }
        token_uri_prefix_.write(token_uri_len - 1, token_uri[token_uri_len - 1]);
        let (local ptr: felt*) = alloc();
        memcpy(ptr, token_uri, token_uri_len - 1);
        _set_token_uri_prefix_(token_uri_len - 1, ptr);
        return ();
    }

    func _set_token_uri_id_infix_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _id_infix: felt
    ) -> () {
        _assert_is_boolean(_id_infix);
        token_uri_id_infix_.write(_id_infix);
        return ();
    }

    func _set_suffix_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_uri_len: felt, token_uri: felt*
    ) -> () {
        alloc_locals;
        if (token_uri_len == 0) {
            return ();
        }
        token_uri_suffix_.write(token_uri_len - 1, token_uri[token_uri_len - 1]);
        let (local ptr: felt*) = alloc();
        memcpy(ptr, token_uri, token_uri_len - 1);
        _set_suffix_uri_(token_uri_len - 1, ptr);
        return ();
    }

    func _get_prefix_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        prefix_uri_len: felt, prefix_uri: felt*
    ) {
        alloc_locals;
        let (prefix_uri) = alloc();
        return _get_prefix_uri_recursion(0, prefix_uri);
    }

    func _get_infix_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _token_id: Uint256
    ) -> (uri_infix_len: felt, uri_infix: felt*) {
        alloc_locals;
        let (has_id_infix) = token_uri_id_infix_.read();
        if (has_id_infix == FALSE) {
            let (null) = alloc();
            return (0, null);
        }
        let (uri_infix_len, uri_infix) = ShortString.uint256_to_ss(_token_id);
        return (uri_infix_len, uri_infix);
    }

    func _get_suffix_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        suffix_uri_len: felt, suffix_uri: felt*
    ) {
        alloc_locals;
        let (suffix_uri) = alloc();
        return _get_suffix_uri_recursion(0, suffix_uri);
    }

    func _get_prefix_uri_recursion{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _prefix_uri_len: felt, _prefix_uri: felt*
    ) -> (prefix_uri_len: felt, prefix_uri: felt*) {
        let (sub_word) = token_uri_prefix_.read(i=_prefix_uri_len);
        if (sub_word == 0) {
            return (_prefix_uri_len, _prefix_uri);
        }
        assert _prefix_uri[_prefix_uri_len] = sub_word;
        return _get_prefix_uri_recursion(_prefix_uri_len + 1, _prefix_uri);
    }

    func _get_suffix_uri_recursion{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _suffix_uri_len: felt, _suffix_uri: felt*
    ) -> (suffix_uri_len: felt, suffix_uri: felt*) {
        let (sub_word) = token_uri_suffix_.read(i=_suffix_uri_len);
        if (sub_word == 0) {
            return (_suffix_uri_len, _suffix_uri);
        }
        assert _suffix_uri[_suffix_uri_len] = sub_word;
        return _get_suffix_uri_recursion(_suffix_uri_len + 1, _suffix_uri);
    }

    func _get_collection_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> (collection_uri_len: felt, collection_uri: felt*) {
        alloc_locals;
        let (collection_uri) = alloc();
        return _get_collection_uri_recursion(0, collection_uri);
    }

    func _get_collection_uri_recursion{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(_collection_uri_len: felt, _collection_uri: felt*) -> (
        collection_uri_len: felt, collection_uri: felt*
    ) {
        let (sub_word) = collection_uri_.read(i=_collection_uri_len);
        if (sub_word == 0) {
            return (_collection_uri_len, _collection_uri);
        }
        assert _collection_uri[_collection_uri_len] = sub_word;
        return _get_collection_uri_recursion(_collection_uri_len + 1, _collection_uri + 1);
    }

    func _set_collection_uri_{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _collection_uri_len: felt, _collection_uri: felt*
    ) -> () {
        if (_collection_uri_len == 0) {
            return ();
        }
        collection_uri_.write(_collection_uri_len, _collection_uri[0]);
        _set_collection_uri_(_collection_uri_len - 1, _collection_uri);
        return ();
    }

    func _assert_is_boolean(x: felt) {
        with_attr error_message("BOOL ERROR") {
            assert (1 - x) * x = 0;
        }
        return ();
    }
}

// Credits to Aspect https://github.com/aspectco/cairo-contracts
namespace ShortString {
    //
    // Converts a uint256 to it's equivalent in a list of felts
    //
    func uint256_to_ss{range_check_ptr}(input: Uint256) -> (res_len: felt, res: felt*) {
        alloc_locals;
        let (local res) = alloc();
        let (input_eq) = uint256_eq(input, Uint256(0, 0));
        if (input_eq == 1) {
            assert res[0] = 48;
            return (res_len=1, res=res);
        }
        let (res_len) = _uint256_to_ss(input, res);
        return (res_len=res_len, res=res);
    }

    func _uint256_to_ss{range_check_ptr}(val: Uint256, res: felt*) -> (res_len: felt) {
        alloc_locals;
        let (val_eq) = uint256_eq(val, Uint256(0, 0));
        if (val_eq == 1) {
            return (res_len=0);
        }
        let (local running_total, remainder) = uint256_to_ss_partial(val);
        let (res_len) = _uint256_to_ss(remainder, res);
        assert res[res_len] = running_total;
        return (res_len=res_len + 1);
    }

    //
    // Converts a uint it's equivalent short string. In the case where the felt length exceeds
    // the maximum short string length (31 bytes), the remainder will be returned
    // - eg. felt(10) -> '10', 0
    // - eg. felt(123 "8*31") -> '8'*31, 123
    //
    func uint256_to_ss_partial{range_check_ptr}(input: Uint256) -> (
        running_total: felt, remainder: Uint256
    ) {
        let (running_total, remainder) = _uint256_to_ss_partial(input, 0);
        return (running_total=running_total, remainder=remainder);
    }

    func _uint256_to_ss_partial{range_check_ptr}(val: Uint256, depth: felt) -> (
        running_total: felt, remainder: Uint256
    ) {
        alloc_locals;
        // Used to shift the word by depth
        let (local word_exponent) = pow(2, 8 * depth);
        let (q, r) = uint256_unsigned_div_rem(val, Uint256(10, 0));
        let (quotient_eq) = uint256_eq(q, Uint256(0, 0));
        if (quotient_eq == 1) {
            let res = word_exponent * (r.low + 48);
            return (running_total=res, remainder=q);
        }
        if (depth == 30) {
            let res = word_exponent * (r.low + 48);
            return (running_total=res, remainder=q);
        }
        let depth = depth + 1;
        let (running_total, remainder) = _uint256_to_ss_partial(q, depth);
        let res = word_exponent * (r.low + 48) + running_total;
        return (running_total=res, remainder=remainder);
    }
}
