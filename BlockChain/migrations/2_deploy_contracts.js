var GameMarket = artifacts.require("GameMarket");
module.exports = function(deployer) {
  deployer.deploy(GameMarket,200,"0x6dcE40955745792685bdb6488062422867E47fbA");
};