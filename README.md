<p align="center"> 
  <img src="images/brilliantblocks_logo.png" alt="brilliantblocks-logo" width="30%" height="30%">
</p>
<h1 align="center"> ERC-2535 </h1>

</br>

This repository contains the code base for a modular smart contract system, which is built as a modified version of the “Diamond” ERC-2535 multi-facet proxy contract.
With this interface standard, smart contracts ("Diamonds") can be assembled from existing functionality components ("Facets") as individually required.
This enables composability and continuous upgradeability for developers.


## Features

- [x] Upgradability
- [x] On-chain deployment
- [x] Dynamic interface detection
- [x] ERC-20 - Fungible Tokens
- [x] ERC-721 - Non-Fungible Tokens
- [x] ERC-1155 - Semi-Fungible Tokens
- [x] ERC-5114 - Soulbound Badges
- [ ] ERC-2981 - Royalties
- [ ] ERC-4675 - Multi-Fractional NFTs


## Repository Overview

The main smart contract aka. *the diamond*:
- [src/diamond](./src/diamond/)

Functional extensions for diamonds aka. *the facets*:
- [src/facets](./src/facets/)

    Configurability and upgradability:
    - [src/facets/upgradability](./src/facets/upgradability)

    Catalog of supported token standards:
    - [src/facets/token](./src/facets/token)

        ERC-1155:
        - [src/facets/token/erc1155](./src/facets/token/erc1155)

        ERC-20:
        - [src/facets/token/erc20](./src/facets/token/erc20)

        ERC-5114:
        - [src/facets/token/erc5114](./src/facets/token/erc5114)

        ERC-721:
        - [src/facets/token/erc721](./src/facets/token/erc721)
    
    Single metadata facet for all token standards:
    - [src/facets/metadata](./src/facets/metadata)
