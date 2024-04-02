// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketplace is ERC721URIStorage {
    uint256 private _tokenCounter;
    uint256 private _itemSoldCounter;
    uint256 public listingPrice = 0.0025 ether;

    address payable public owner;

    mapping(uint256 => MarketItem) private idMarketItem;
    mapping(uint256 => uint256) public tokenRoyalties;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    event MarketItemSold(
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price
    );

    event AuctionStarted(
        uint256 indexed tokenId,
        address seller,
        uint256 startingPrice,
        uint256 reservePrice,
        uint256 duration
    );

    event AuctionEnded(
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price
    );

    event RoyaltiesUpdated(uint256 indexed tokenId, uint256 royalty);

    event Withdrawal(address indexed _to, uint256 _amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can change the listing price");
        _;
    }

    constructor() ERC721("ARTHIVE", "THIVE") {
        owner = payable(msg.sender);
    }

    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createToken(string memory tokenURI, uint256 price) public payable returns (uint256) {
        _tokenCounter++;

        uint256 newTokenId = _tokenCounter;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price should be greater than zero");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);

        emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    function reSellToken(uint256 tokenId, uint256 price) public payable {
        require(idMarketItem[tokenId].owner == msg.sender, "Only item owner can re-sell");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(this));

        _itemSoldCounter--;

        _transfer(msg.sender, address(this), tokenId);
    }

    function createMarketSale(uint256 tokenId) public payable {
        uint256 price = idMarketItem[tokenId].price;

        require(msg.value == price, "Provide the asking price to complete the order");

        idMarketItem[tokenId].owner = payable(msg.sender);
        idMarketItem[tokenId].sold = true;
        idMarketItem[tokenId].seller = payable(address(0));

        _itemSoldCounter++;

        _transfer(address(this), msg.sender, tokenId);

        emit MarketItemSold(tokenId, idMarketItem[tokenId].seller, msg.sender, price);

        // Transfer funds to the seller and listing fee to the owner
        payable(owner).transfer(listingPrice);
        payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }

    function startAuction(
        uint256 tokenId,
        uint256 startingPrice,
        uint256 reservePrice,
        uint256 duration
    ) public {
        // Implement auction functionality here
        emit AuctionStarted(tokenId, msg.sender, startingPrice, reservePrice, duration);
    }

    function endAuction(uint256 tokenId) public {
        // Implement auction ending logic here
        emit AuctionEnded(tokenId, msg.sender, address(0), 0);
    }

    function setRoyalty(uint256 tokenId, uint256 royalty) public onlyOwner {
        require(royalty <= 10000, "Royalty percentage must be less than or equal to 100%");
        tokenRoyalties[tokenId] = royalty;
        emit RoyaltiesUpdated(tokenId, royalty);
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenCounter;
        uint256 unSoldItemCount = _tokenCounter - _itemSoldCounter;
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unSoldItemCount);
        for (uint256 i = 1; i <= itemCount; i++) {
            if (!idMarketItem[i].sold) {
                items[currentIndex] = idMarketItem[i];
                currentIndex++;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenCounter;
        uint256 myItemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemCount; i++) {
            if (idMarketItem[i].owner == msg.sender) {
                myItemCount++;
            }
        }

        MarketItem[] memory myItems = new MarketItem[](myItemCount);
        for (uint256 i = 1; i <= itemCount; i++) {
            if (idMarketItem[i].owner == msg.sender) {
                myItems[currentIndex] = idMarketItem[i];
                currentIndex++;
            }
        }
        return myItems;
    }

    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenCounter;
        uint256 listedItemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemCount; i++) {
            if (idMarketItem[i].seller == msg.sender) {
                listedItemCount++;
            }
        }

        MarketItem[] memory listedItems = new MarketItem[](listedItemCount);
        for (uint256 i = 1; i <= itemCount; i++) {
            if (idMarketItem[i].seller == msg.sender) {
                listedItems[currentIndex] = idMarketItem[i];
                currentIndex++;
            }
        }
        return listedItems;
    }

    // Allows the contract owner to withdraw Ether from the contract
    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance");
        owner.transfer(_amount);
        emit Withdrawal(owner, _amount);
    }
}
