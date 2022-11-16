%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.cairo.common.math import assert_not_zero

from src.ERC5114.IERC5114 import NFT

@event
func Mint(token_id: Uint256, nft: NFT) {
}

@storage_var
func _owners(token_id: Uint256) -> (nft: NFT) {
}

@storage_var
func _metadata_format() -> (res: felt) {
}

namespace ERC5114 {
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        metadata_format: felt
    ) {
        with_attr error_message("Metadata format must not be zero") {
            assert_not_zero(metadata_format);
        }
        _metadata_format.write(metadata_format);
        return ();
    }

    func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        token_id: Uint256, nft: NFT
    ) -> () {
        with_attr error_message("SBT is not a valid Uint256") {
            uint256_check(token_id);
        }
        with_attr error_message("NFT is not a valid Uint256") {
            uint256_check(nft.id);
        }

        let (exists) = _exists(token_id);
        with_attr error_message("SBT already bound") {
            assert exists = FALSE;
        }

        _owners.write(token_id, nft);
        Mint.emit(token_id, nft);
        return ();
    }

    func owner_of{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        token_id: Uint256
    ) -> (nft: NFT) {
        with_attr error_message("SBT input must be a Uint256") {
            uint256_check(token_id);
        }
        let (nft) = _owners.read(token_id);

        with_attr error_message("SBT is nonexistent") {
            assert_not_zero(nft.address);
        }

        return (nft,);
    }

    func metadata_format{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        metadata_format: felt
    ) {
        let (metadata_format) = _metadata_format.read();

        return (metadata_format,);
    }

    func _exists{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_id: Uint256
    ) -> (bool: felt) {
        let (exists) = _owners.read(token_id);

        if (exists.address == FALSE) {
            return (FALSE,);
        }

        return (TRUE,);
    }
}
