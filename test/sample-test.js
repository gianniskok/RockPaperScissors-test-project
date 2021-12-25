const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("Game", function() {
  let Token;
  let token;
  let RockPaperScissors;
  let rockPaperScissors;
  let winner;
  beforeEach(async function () {
    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy(1000000000);
  
    RockPaperScissors = await ethers.getContractFactory("RockPaperScissors");
    rockPaperScissors = await RockPaperScissors.deploy(token.address);
  
    [owner, user1, user2] = await ethers.getSigners()
    await token.setAproveInitialize(rockPaperScissors.address);
  });
  
  describe("RockPaperScissors", function() {
    it("Should have p1 win an open game", async function() {
      await rockPaperScissors.connect(owner).createUser("Player1");
      await rockPaperScissors.connect(owner).createGame(5, [0,0,0]); //5 tokens and Rock,Rock,Rock
      await rockPaperScissors.connect(owner).createGame(3, [0,0,0]); //3 tokens and Rock,Rock,Rock
      await rockPaperScissors.connect(owner).createGame(7, [0,0,0]); //7 tokens and Rock,Rock,Rock
      await rockPaperScissors.connect(user1).createUser("Player2");
      await rockPaperScissors.connect(user1).buyToken(1000)
      await token.connect(user1).approve(rockPaperScissors.address, 1000)
      await rockPaperScissors.connect(user1).joinGame([2,2,2], 5); // 5 tokens and Scissors,Scissors,Scissors
      // await winner.wait()
      const user1Balance = await token.balanceOf(user1.address)
      expect(user1Balance).to.equal(995) // lost 5 tokens
      expect(rockPaperScissors.connect(user1).joinGame([2,2,2], 5)).to.be.revertedWith("A0")// no more games with 5 tokens available
    });

    it("Should have p1 win a private game", async function() {
      await rockPaperScissors.connect(owner).createUser("Player1");
      await rockPaperScissors.connect(owner).createCustomGame(user1.address, 5, [0,0,0]); //5 tokens and Rock,Rock,Rock
      await rockPaperScissors.connect(user2).createUser("Player3");
      await rockPaperScissors.connect(user2).buyToken(1000)
      await token.connect(user2).approve(rockPaperScissors.address, 1000)
      expect(rockPaperScissors.connect(user2).joinCustomGame(rockPaperScissors.privatequeue(0), [1,1,1])).to.be.revertedWith("NVU")// no more games with 5 tokens available
      await rockPaperScissors.connect(user1).createUser("Player2");
      await rockPaperScissors.connect(user1).buyToken(1000)
      await token.connect(user1).approve(rockPaperScissors.address, 1000)
      await rockPaperScissors.connect(user1).joinCustomGame(rockPaperScissors.privatequeue(0), [2,2,2]); // 5 tokens and Scissors,Scissors,Scissors
      // await winner.wait()
      const user1Balance = await token.balanceOf(user1.address)
      expect(user1Balance).to.equal(995) // lost 5 tokens
 
    });
  });
  
});
