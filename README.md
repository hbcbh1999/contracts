# Kiosk

Kiosk is a protocol for decentralized commerce using Ethereum smart contracts.

With the Kiosk protocol, merchants can:
* Register a globally unique product identifier for each of their products
* Manage product information and pricing off-chain using existing e-commerce platforms
* Sell products directly to buyers with no middlemen and no transaction fees

...and buyers can:
* Add products to a universal shopping cart
* Purchase products without navigating through the checkout process of an e-commerce website

## Quick Start

The following tutorials will prepopulate the relevant smart contracts in [Remix](http://remix.ethereum.org/), an online [Solidity](https://solidity.readthedocs.io/en/develop/) compiler.

* [Register an Identifier](https://ethereum.github.io/browser-solidity/#version=soljson-v0.4.16+commit.d7661dd9.js&optimize=undefined&gist=d0bcf511375abcefc6a20dfaf9bc8be1)
* [Add a Product](https://ethereum.github.io/browser-solidity/#version=soljson-v0.4.16+commit.d7661dd9.js&optimize=undefined&gist=712a758e7de8b2614d00bd38695de2c3)
* [Buy a Product](https://ethereum.github.io/browser-solidity/#version=soljson-v0.4.17+commit.bdeb9e52.js&optimize=undefined&gist=8c78f3b79004115d3c4276a554482ee4)

## Testing

Requirements:
* Install [Node.js](https://nodejs.org/en/)
* Install [Truffle](http://truffleframework.com/) 
* Install [testrpc](https://github.com/ethereumjs/testrpc)

Download the project and install its dependencies.
```
git clone https://github.com/kioskprotocol/contracts.git
npm install
```

In a separate terminal tab, start testrpc.
```
testrpc
```

Then, in the root directory of the project, run the tests with Truffle.
```
truffle test
```

## How It Works

### DIN

A Decentralized Identification Number (DIN) is a globally unique, 10-digit number that can be used for product identification.

### Register a New DIN

You can register a new identifier for your product via the [DINRegistrar](contracts/DINRegistrar.sol) smart contract.

```
function registerDIN() returns (uint256 DIN)
function registerDINs(uint256 quantity) // Maximum of 10 in a single transaction.
```

### Resolver

A resolver contract is responsible for managing product information.

### Add a Resolver for Your Product

A resolver must implement the following methods:

```
function supportsInterface(bytes4 interfaceID) constant returns (bool)
function productURL(uint256 DIN) public constant returns (string)
```

For now, only URL resolvers are supported. In the future, we may add support for [IPFS](https://ipfs.io/) and other types of resolvers.

If you are only listing a few products, you should use the [PublicURLResolver](contracts/PublicURLResolver.sol). Otherwise, you can deploy your own [URLResolver](contracts/URLResolver.sol) contract.

```
contract MyURLResolver is URLResolver {
    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;         // bytes4(sha3("supportsInterface(bytes4)"))
    bytes4 constant PRODUCT_URL_INTERFACE_ID = 0xaf655719;  // bytes4(sha3("productURL(uint256)"))
    
    function supportsInterface(bytes4 interfaceID) public constant returns (bool) {
        return interfaceID == INTERFACE_META_ID ||
               interfaceID == PRODUCT_URL_INTERFACE_ID;
    }

    function productURL(uint256 DIN) public constant returns (string) {
        return "https://www.api.myproducts.com/";
    }
}
```

The Kiosk protocol will find the product URL for a given DIN and pass in the DIN as a parameter. For example, if the owner of DIN `1000000001` sets the above resolver for his product, a client should be able to retrieve the relevant product information from:

```
https://www.api.myproducts.com/1000000001
```

After your resolver is configured, be sure to update the [DINRegistry](contracts/DINRegistry.sol) with its address.

```
function setResolver(uint256 DIN, address resolver)
```

### Response Schema

Your product URL must implement a specific JSON schema so that clients of the Kiosk protocol can easily parse product information. The response schema includes the following properties of the schema.org [Product](http://schema.org/Product) and [Offer](http://schema.org/Offer) types: 
* `name`
* `image`
* `description`
* `brand`
* `url`
* `price`
* `priceCurrency`
* `priceValidUntil`

To make the product available for purchase, you must also add elliptic curve signature parameters to validate that the `price` and `priceValidUntil` properties were set by the account owner as well as a `checkoutURL` where a frontend client that implements the Kiosk protocol can `POST` the buyer's delivery address. A tutorial for this will be available soon.

#### Example Response

```
{
  "name": "Kiosk T-Shirt",
  "image": [
    "https://vangogh.teespring.com/shirt_pic/22611585/23621266/2/6046/480x9999/front.jpg?v=2017-09-27-22-25"
  ],
  "description": "A blue T-shirt with the Kiosk logo",
  "brand": "Kiosk",
  "url": "https://teespring.com/kiosk-demo#pid=2&cid=6046&sid=front",
  "price": "1000000000000000000",
  "priceCurrency": "0x0000000000000000000000000000000000000000" // ERC20 token address. 0x0... represents Ether.
  "priceValidUntil": 1514160000,
  "checkoutURL": "https://www.mycheckouthandler.com/",
  "ecSignature": {
    "v": 27,
    "r": "0x4c740f7977d2c78a09806ad2d994884f7a6b8d38ba7a4e1d631b6d2a237487e5",
    "s": "0x4d4d17af44edaa28cc5ff3ab70f43b20a07be640f2c2b8d9f7444f271e0030d8"
  }
}
```

We will add plug-ins for popular e-commerce platforms like WooCommerce, Shopify, and Magento to make this process as easy as possible. Stay tuned!

## Deployed Contracts

**[DINRegistry.sol](contracts/DINRegistry.sol)**
```
Ethereum Main Network Address: 0x79bf32b2c0f9a3f30fbcc4aa1e3e07e3366b34f9
Kovan Test Network Address: 0xa26993945449FE1BdF22253fd2583dA184e90B56

ABI: 
[{"constant":true,"inputs":[{"name":"DIN","type":"uint256"}],"name":"resolver","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"registrar","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"DIN","type":"uint256"},{"name":"owner","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"DIN","type":"uint256"}],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"genesis","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"DIN","type":"uint256"}],"name":"updated","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"DIN","type":"uint256"},{"name":"resolver","type":"address"}],"name":"setResolver","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"DIN","type":"uint256"},{"name":"owner","type":"address"}],"name":"register","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_registrar","type":"address"}],"name":"setRegistrar","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"_genesis","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"DIN","type":"uint256"},{"indexed":true,"name":"owner","type":"address"}],"name":"NewOwner","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"DIN","type":"uint256"},{"indexed":true,"name":"resolver","type":"address"}],"name":"NewResolver","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"DIN","type":"uint256"},{"indexed":true,"name":"owner","type":"address"}],"name":"NewRegistration","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"registrar","type":"address"}],"name":"NewRegistrar","type":"event"}]
```

**[DINRegistrar.sol](contracts/DINRegistrar.sol)**
```
Ethereum Main Network Address: 0xcfe8f8dcd29419ba396a496ad2317b784ec23d60
Kovan Test Network Address: 0xe41d67a3e7866f84bd5db17492a744de23b08df2

ABI: 
[{"constant":false,"inputs":[],"name":"registerDIN","outputs":[{"name":"DIN","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"index","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"quantity","type":"uint256"}],"name":"registerDINs","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"MAX_QUANTITY","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_registry","type":"address"},{"name":"_genesis","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"}]
```

**[PublicURLResolver.sol](contracts/PublicURLResolver.sol)**
```
Kovan Test Network Address: 0xA9b81c7d571717f0817688252EF2C9cCc039B939

ABI: 
[{"constant":true,"inputs":[{"name":"interfaceID","type":"bytes4"}],"name":"supportsInterface","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"DIN","type":"uint256"}],"name":"productURL","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"DIN","type":"uint256"},{"name":"URL","type":"string"}],"name":"setProductURL","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"_registry","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"}]
```

**[StandardResolver.sol](contracts/StandardResolver.sol)**
```
// Use ResolverFactory to create a new StandardResolver.

ABI:
[{"constant":true,"inputs":[{"name":"interfaceID","type":"bytes4"}],"name":"supportsInterface","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"DIN","type":"uint256"}],"name":"merchant","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_productURL","type":"string"}],"name":"setProductURL","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"productURL","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"registry","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_merchant","type":"address"}],"name":"setMerchant","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"merchant","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"DIN","type":"uint256"}],"name":"productURL","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_registry","type":"address"},{"name":"_owner","type":"address"},{"name":"_productURL","type":"string"},{"name":"_merchant","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"}]
```

**[ResolverFactory.sol](contracts/ResolverFactory.sol)**
```
Kovan Test Network Address: 0x70d50a8041ca55b72f2b273651bd0caf7e3bc078

ABI:
[{"constant":true,"inputs":[],"name":"registry","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"productURL","type":"string"},{"name":"merchant","type":"address"}],"name":"createResolver","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"_registry","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"resolver","type":"address"},{"indexed":true,"name":"owner","type":"address"},{"indexed":false,"name":"productURL","type":"string"},{"indexed":true,"name":"merchant","type":"address"}],"name":"NewResolver","type":"event"}]
```

**[MarketToken.sol](contracts/MarketToken.sol)**
```
// On test networks, Market Token has an additional method called getTokens for testing purposes. 
// When deployed to the Ethereum Main Network, tokens will be distributed using a crowdsale contract.

Kovan Test Network Address: 0x0d5446bA988880881445791a6d8aec96d9bc9B11
Kovan ABI:
[{"constant":true,"inputs":[],"name":"checkout","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFromCheckout","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_subtractedValue","type":"uint256"}],"name":"decreaseApproval","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"FREE_TOKENS","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"getTokens","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_checkout","type":"address"}],"name":"setCheckout","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_addedValue","type":"uint256"}],"name":"increaseApproval","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_totalSupply","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"}],"name":"NewOwner","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"buy","type":"address"}],"name":"NewBuy","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]
```

**[Checkout.sol](contracts/Checkout.sol)**
```
Kovan Test Network Address: 0x5cc013cad69270c6a2e6d8daee4a79f1c105e13a

ABI:
[{"constant":true,"inputs":[],"name":"orderIndex","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"registry","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"signer","type":"address"},{"name":"hash","type":"bytes32"},{"name":"v","type":"uint8"},{"name":"r","type":"bytes32"},{"name":"s","type":"bytes32"}],"name":"isValidSignature","outputs":[{"name":"valid","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"orderValues","type":"uint256[5]"},{"name":"orderAddresses","type":"address[2]"},{"name":"v","type":"uint8"},{"name":"r","type":"bytes32"},{"name":"s","type":"bytes32"}],"name":"buy","outputs":[{"name":"orderID","type":"uint256"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[],"name":"marketToken","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_token","type":"address"},{"name":"_registry","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"error","type":"string"}],"name":"LogError","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"orderID","type":"uint256"},{"indexed":true,"name":"buyer","type":"address"},{"indexed":true,"name":"merchant","type":"address"},{"indexed":false,"name":"DIN","type":"uint256"},{"indexed":false,"name":"quantity","type":"uint256"},{"indexed":false,"name":"totalPrice","type":"uint256"},{"indexed":false,"name":"priceCurrency","type":"address"},{"indexed":false,"name":"timestamp","type":"uint256"}],"name":"NewOrder","type":"event"}]
```

**[Cart.sol](contracts/Cart.sol)**
```
Kovan Test Network Address: 0xf72CC66521D3c24d58aeF6F3697E5C8a386D999e

ABI:
[{"constant":false,"inputs":[{"name":"DIN","type":"uint256"}],"name":"addToCart","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"DIN","type":"uint256"},{"indexed":true,"name":"buyer","type":"address"}],"name":"AddToCart","type":"event"}]

