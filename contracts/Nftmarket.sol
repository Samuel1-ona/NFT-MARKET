// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VideoNFTMarket is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;

    struct VideoToken {
        uint256 tokenId;
        address mintedBy;
        string videoLink;
        uint256 sellingPrice;
        bool isListedForSale;
    }

    mapping(uint256 => VideoToken) private _gameTokens;
    mapping(address => bool) private _permittedMinters;




    constructor() ERC721("GameTokenCoolection", "GTC") {}

    modifier minterOnly() {
        require(_permittedMinters[msg.sender], "Unauthorized minter");
        _;
    }

    function authorizeMinter(address minter) external {
        require(minter != address(0), "Minter address cannot be zero");
        _permittedMinters[minter] = true;
    }

    function revokeMinter(address minter) external {
        require(minter != address(0), "Minter address cannot be zero");
        _permittedMinters[minter] = false;
    }

    function createNFT(string memory gameLink, uint256 price) external minterOnly {
        _tokenIdTracker.increment();
        uint256 tokenId = _tokenIdTracker.current();
        _mint(msg.sender, tokenId);

        VideoToken memory newVideoToken = VideoToken({
            tokenId: tokenId,
            mintedBy: msg.sender,
            videoLink: videoLink,
            sellingPrice: price,
            isListedForSale: false
        });

        _videoTokens[tokenId] = newVideoToken;
    }

    function purchaseNFT(uint256 tokenId) external payable {
        VideoToken storage videoToken = _videoTokens[tokenId];
        require(videoToken.isListedForSale, "This NFT is not on sale");
        require(msg.value >= videoToken.sellingPrice, "Payment is below the price");

        address payable currentOwner = payable(ownerOf(tokenId));
        currentOwner.transfer(msg.value);

        _transfer(currentOwner, msg.sender, tokenId);
        videoToken.isListedForSale = false;
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        
        VideoToken storage videoToken = _videoTokens[tokenId];
        require(!videoToken.isListedForSale, "NFT is already listed for sale");

        videoToken.sellingPrice = price;
        videoToken.isListedForSale = true;
    }

    function fetchNFTDetails(uint256 tokenId) external view returns (uint256, address, string memory, uint256, bool) {
        VideoToken memory videoToken = _videoTokens[tokenId];
        return (videoToken.tokenId, videoToken.mintedBy, videoToken.videoLink, videoToken.sellingPrice, videoToken.isListedForSale);
    }
}
