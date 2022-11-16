%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.uint256 import Uint256

from starkware.starknet.common.syscalls import get_contract_address

from src.constants import (
    FUNCTION_SELECTORS,
    IERC20_ID,
    IERC721_ID,
    IERC1155_ID,
    IERC5114_ID,
    IERC20_METADATA_ID,
    IERC721_METADATA_ID,
    IERC1155_METADATA_ID,
    IERC5114_METADATA_ID,
    NULL,
)
from src.ERC2535.IDiamond import IDiamond
from src.UniversalMetadata.library import Library, UniversalMetadata

@view
func decimals{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let decimals = UniversalMetadata._get_decimals_();
    return (res=decimals);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let name = UniversalMetadata._get_name_();
    return (res=name);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let symbol = UniversalMetadata._get_name_();
    return (res=symbol);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _tokenId: Uint256
) -> (res_len: felt, res: felt*) {
    let (tokenURI_len, tokenURI) = UniversalMetadata._get_token_uri_(_tokenId);
    return (tokenURI_len, tokenURI);
}

@view
func uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_tokenId: Uint256) -> (
    res_len: felt, res: felt*
) {
    let (uri_len, uri) = UniversalMetadata._get_token_uri_(_tokenId);
    return (uri_len, uri);
}

@view
func metadataFormat{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let metadataFormat = UniversalMetadata._get_metadata_format_();
    return (res=metadataFormat);
}

@view
func tokenUri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _tokenId: Uint256
) -> (res_len: felt, res: felt*) {
    let (tokenUri_len, tokenUri) = UniversalMetadata._get_token_uri_(_tokenId);
    return (tokenUri_len, tokenUri);
}

@view
func collectionUri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res_len: felt, res: felt*
) {
    let (collectionUri_len, collectionUri) = UniversalMetadata._get_collection_uri_();
    return (collectionUri_len, collectionUri);
}

// ===================
// Mandatory functions
// ===================

// / @dev Initialize this facet
// / @revert BOOL ERROR if _has_token_id_infix is not a boolean
@external
func __constructor__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _decimals: felt,
    _name: felt,
    _symbol: felt,
    _prefix_uri_len: felt,
    _prefix_uri: felt*,
    _has_token_id_infix: felt,
    _suffix_uri_len: felt,
    _suffix_uri: felt*,
    _collection_uri_len: felt,
    _collection_uri: felt*,
) -> () {
    Library._assert_is_boolean(_has_token_id_infix);
    UniversalMetadata._set_decimals_(_decimals);
    UniversalMetadata._set_name_(_name);
    UniversalMetadata._set_symbol_(_symbol);
    UniversalMetadata._set_token_uri_(
        _prefix_uri_len, _prefix_uri, _has_token_id_infix, _suffix_uri_len, _suffix_uri
    );
    UniversalMetadata._set_collection_uri_(_collection_uri_len, _collection_uri);
    return ();
}

// / @dev Remove this facet
// / @notice Resets all metadata
@external
func __destructor__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
    alloc_locals;
    let (local NULLptr: felt*) = alloc();
    UniversalMetadata._set_decimals_(NULL);
    UniversalMetadata._set_name_(NULL);
    UniversalMetadata._set_symbol_(NULL);
    UniversalMetadata._set_token_uri_(NULL, NULLptr, FALSE, NULL, NULLptr);
    UniversalMetadata._set_collection_uri_(NULL, NULLptr);
    return ();
}

// / @dev Exported view and invokable functions of this facet
@view
@raw_output
func __get_function_selectors__{syscall_ptr: felt*, range_check_ptr}() -> (
    retdata_size: felt, retdata: felt*
) {
    alloc_locals;
    let (local NULLptr: felt*) = alloc();
    let (self) = get_contract_address();

    let (is_erc20) = IDiamond.supportsInterface(self, IERC20_ID);
    if (is_erc20 == TRUE) {
        let (func_selectors) = get_label_location(ERC20selectors_start);
        return (retdata_size=3, retdata=cast(func_selectors, felt*));
    }

    let (is_erc721) = IDiamond.supportsInterface(self, IERC721_ID);
    if (is_erc721 == TRUE) {
        let (func_selectors) = get_label_location(ERC721selectors_start);
        return (retdata_size=3, retdata=cast(func_selectors, felt*));
    }

    let (is_erc1155) = IDiamond.supportsInterface(self, IERC1155_ID);
    if (is_erc1155 == TRUE) {
        let (func_selectors) = get_label_location(ERC1155selectors_start);
        return (retdata_size=1, retdata=cast(func_selectors, felt*));
    }

    let (is_erc5114) = IDiamond.supportsInterface(self, IERC5114_ID);
    if (is_erc5114 == TRUE) {
        let (func_selectors) = get_label_location(ERC5114selectors_start);
        return (retdata_size=3, retdata=cast(func_selectors, felt*));
    }

    return (retdata_size=NULL, retdata=NULLptr);

    ERC20selectors_start:
    dw FUNCTION_SELECTORS.ERC20Metadata.decimals;
    dw FUNCTION_SELECTORS.ERC20Metadata.name;
    dw FUNCTION_SELECTORS.ERC20Metadata.symbol;

    ERC721selectors_start:
    dw FUNCTION_SELECTORS.ERC721Metadata.name;
    dw FUNCTION_SELECTORS.ERC721Metadata.symbol;
    dw FUNCTION_SELECTORS.ERC721Metadata.tokenURI;

    ERC1155selectors_start:
    dw FUNCTION_SELECTORS.ERC1155Metadata.uri;

    ERC5114selectors_start:
    dw FUNCTION_SELECTORS.ERC5114Metadata.collectionUri;
    dw FUNCTION_SELECTORS.ERC5114Metadata.metadataFormat;
    dw FUNCTION_SELECTORS.ERC5114Metadata.tokenUri;
}

// / @dev Define all supported interfaces of this facet
@view
func __supports_interface__{syscall_ptr: felt*, range_check_ptr}(_interface_id: felt) -> (
    res: felt
) {
    alloc_locals;
    let (self) = get_contract_address();

    if (_interface_id == IERC20_METADATA_ID) {
        return IDiamond.supportsInterface(self, IERC20_ID);
    }
    if (_interface_id == IERC721_METADATA_ID) {
        return IDiamond.supportsInterface(self, IERC721_ID);
    }
    if (_interface_id == IERC1155_METADATA_ID) {
        return IDiamond.supportsInterface(self, IERC1155_ID);
    }
    if (_interface_id == IERC5114_METADATA_ID) {
        return IDiamond.supportsInterface(self, IERC5114_ID);
    }

    return (res=FALSE);
}
