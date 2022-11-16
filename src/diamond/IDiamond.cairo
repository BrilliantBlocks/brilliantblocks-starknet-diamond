%lang starknet

@contract_interface
namespace IDiamond {
    // @selector 0x2d239fcc6e2e069671847938814792449cfdc634d0e0f97064b7d58549ff0a3
    func facetAddress(_func_sel: felt) -> (class: felt) {
    }

    // @selector 0x8c53917c89dfbbea7ca3be797295a4c92851cb2eb28c014026d322a58680fd
    func facetAddresses() -> (class_len: felt, class: felt*) {
    }

    // @selector 0x4bb7058cddb3b18bb278022ad8fc6e40862c760037947effce18316d7630ed
    func facetFunctionSelectors(_facet: felt) -> (fun_sel_len: felt, fun_sel: felt*) {
    }

    // @selector 0xbac999a4f417420eb3cb0b9e60b068ce3b1556d9cc8a323c637a123572d61d
    func facets() -> (class_len: felt, class: felt*) {
    }

    // @selector 0xe6e07b52b12817e02c0dc9ca9aeca6d3ed079f472de5e7b8024f6146a7f3c
    func getImplementation() -> (class: felt) {
    }

    // @selector 0x29e211664c0b63c79638fbea474206ca74016b3e9a3dc4f9ac300ffd8bdf2cd
    func supportsInterface(_interface_id: felt) -> (res: felt) {
    }

    // @selector 0x3cfa801b3ef3b42e585d0381132bc99e75cb1b6a7d45c15f7b245ee8c8d4104
    func getRoot() -> (address: felt) {
    }
}
