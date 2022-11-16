# ERC-2535

ERC-2535 is a multi-proxy which excels with flexibility and elegance in solving the upgradability problem for smart contracts.
Thus, they are a suitable starting point for virtually any DApp.


## Root Diamond

Each diamond is related to a root diamond.
The root diamond has two roles:

- a factory for new diamonds
- a registry for facets


## Finished and Unfinished Diamonds

A diamond can be classified into two categories.
A diamond is called finished iff it does not include the DiamondCut facet and thus being **immutable**.
Else, a diamond is unfinished and **immutable**.


## Dynamic Interface Detection

A diamond is aware of its integrated facets and can even distinguish token standards.
This is accomplished by a set of detection functions.
Thus, interface detection functions like `getImplementation()` or ERC-165 `supportsInterface()` return depending on their currently integrated facets.
