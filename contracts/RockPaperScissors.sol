//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Game.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Users.sol";

contract RockPaperScissors is Users{

    address tokenAddress;
    address[] activequeue;
    address[] privatequeue;
    mapping(address => bool) available;
    mapping(address => address) player2PerCustom;
    uint256 activeindex;
    uint256 randNonce = 0;

    constructor(address _tokenAdd) Users(){
        tokenAddress = _tokenAdd;
    }

    function createGame(uint16 _wage, uint8[3] memory _choices) external  activeUser{
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _wage);
        Game newGame = new Game(msg.sender, _wage, _choices);
        activequeue.push(address(newGame));
        available[address(newGame)] = true;
    }
    
    function findGame(uint16 _wage) internal view  activeUser returns(address) {
        address[] memory availableList;
        uint256 currentIndex = 0;

        for(uint256 i=0; i< activequeue.length -1; i++){
            if((available[activequeue[i]] == true) && (Game(activequeue[i]).wages() == _wage)){
                availableList[currentIndex] = activequeue[i];
                currentIndex++;
            }
        }
        uint num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % availableList.length;
        return availableList[num];
    } 

    function joinGame(uint8[3] memory _choices, uint16 _wage) external activeUser{
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _wage,"NEB"); //Not enough balance
        address _gameAdd = findGame(_wage);
        require(available[_gameAdd] == true,"NA");
        randNonce++;
        address winner = Game(_gameAdd).addPlayer2(msg.sender, _choices);
        address player1 =  Game(_gameAdd).player1();
        uint16 wage = Game(_gameAdd).wages();
        available[_gameAdd] = false;
        if(winner != address(0)){
            if(winner == msg.sender){
                IERC20(tokenAddress).transferFrom(player1, msg.sender, wage);
            }else {
                IERC20(tokenAddress).transferFrom(msg.sender, player1, wage);
            }
        }
    }

    function createCustomGame(address _player2, uint16 _wages, uint8[3] memory _p1Choices) external  userExists {
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _wages);
        Game newGame = new Game(msg.sender, _wages, _p1Choices);
        privatequeue.push(address(newGame));        
        player2PerCustom[address(newGame)] = _player2;
        available[address(newGame)] = true;
    }

    function joinCustomGame(address _gameAdd, uint8[3] memory _p2Choices) external  userExists {
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= Game(_gameAdd).wages(),"NEB"); //Not enough balance
        require(available[_gameAdd] == true,"NA");
        require(player2PerCustom[_gameAdd] == msg.sender, "NVU"); // Not valid user
        address winner = Game(_gameAdd).addPlayer2(msg.sender, _p2Choices);
        uint16 wage = Game(_gameAdd).wages();
        address player1 =  Game(_gameAdd).player1();
        available[_gameAdd] = false;
        if(winner != address(0)){
            if(winner == msg.sender){
                IERC20(tokenAddress).transferFrom(player1, msg.sender, wage);
            }else {
                IERC20(tokenAddress).transferFrom(msg.sender, player1, wage);
            }
        }
    }

    

}