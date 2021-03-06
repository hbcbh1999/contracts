pragma solidity ^0.4.11;

import "./Resolver.sol";
import "./DINRegistry.sol";

/** @title A resolver contract that can be used for a single merchant with many products */
contract StandardResolver is Resolver {
    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;         // bytes4(keccak256("supportsInterface(bytes4)"))
    bytes4 constant PRODUCT_URL_INTERFACE_ID = 0xaf655719;  // bytes4(keccak256("productURL(uint256)"))
    bytes4 constant MERCHANT_INTERFACE_ID = 0x90a9f8b8;     // bytes4(keccak256("merchant(uint256)"))

    DINRegistry public registry;
    string url;
    address merchantAddr;
    address public owner;

    modifier only_owner {
        require(owner == msg.sender);
        _;
    }

    function StandardResolver(
        DINRegistry _registry,
        address _owner,
        string _productURL,
        address _merchant
    ) 
        public
    {
        owner = _owner;
        registry = _registry;
        url = _productURL;
        merchantAddr = _merchant;
    }

    function supportsInterface(bytes4 interfaceID) public constant returns (bool) {
        return interfaceID == INTERFACE_META_ID ||
               interfaceID == PRODUCT_URL_INTERFACE_ID ||
               interfaceID == MERCHANT_INTERFACE_ID;
    }

    function productURL(uint256 DIN) public constant returns (string) {
        return url;
    }

    function setProductURL(string _productURL) public only_owner {
        url = _productURL;
    }

    function merchant(uint256 DIN) public constant returns (address) {
        return merchantAddr;
    }

    function setMerchant(address _merchant) public only_owner {
        merchantAddr = _merchant;
    }

    function setOwner(address _owner) public only_owner {
        owner = _owner;
    }

}