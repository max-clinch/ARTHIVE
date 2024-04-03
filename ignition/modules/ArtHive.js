const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ArtHiveModule", (m) => {
  const ArtHive = m.contract("ArtHive")
  const listingPrice = m.getParameter("listingPrice", "0.0025 ether"); // Corrected the value

  function createToken(tokenURI, price) {
    return m.invoke("createToken", [tokenURI, price], { payable: true });
  }

  function createMarketItem(tokenId, price) {
    return m.invoke("createMarketItem", [tokenId, price], { payable: true });
  }

  function reSellToken(tokenId, price) {
    return m.invoke("reSellToken", [tokenId, price], { payable: true });
  }

  function createMarketSale(tokenId) {
    return m.invoke("createMarketSale", [tokenId], { payable: true });
  }

  function startAuction(tokenId, startingPrice, reservePrice, duration) {
    return m.invoke("startAuction", [tokenId, startingPrice, reservePrice, duration]);
  }

  function endAuction(tokenId) {
    return m.invoke("endAuction", [tokenId]);
  }

  function setRoyalty(tokenId, royalty) {
    return m.invoke("setRoyalty", [tokenId, royalty]);
  }

  function fetchMarketItems() {
    return m.invoke("fetchMarketItems", [], { view: true });
  }

  function fetchMyNFTs() {
    return m.invoke("fetchMyNFTs", [], { view: true });
  }

  function fetchItemsListed() {
    return m.invoke("fetchItemsListed", [], { view: true });
  }

  function withdraw(amount) {
    return m.invoke("withdraw", [amount]);
  }

  return {
    ArtHive,
    createToken,
    createMarketItem,
    reSellToken,
    createMarketSale,
    startAuction,
    endAuction,
    setRoyalty,
    fetchMarketItems,
    fetchMyNFTs,
    fetchItemsListed,
    withdraw,
    listingPrice,
  };
});