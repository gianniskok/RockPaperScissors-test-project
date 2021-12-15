//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Game.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Users.sol";

contract Init is Users{

    address tokenAddress;
    address[] activequeue;
    mapping(address => bool) available;
    uint256 activeindex;

    constructor(address _tokenAdd) {
        tokenAddress = _tokenAdd;
    }

    function createGame(uint16 _wage, uint8[3] memory _choices) external activeUser{
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _wage);
        Game newGame = new Game(msg.sender, _wage, _choices);
        activequeue.push(address(newGame));
        available[address(newGame)] = true;
    }
    function findGame(uint16 _wage) external view activeUser returns(address[] memory) {
        address[] memory availableList;
        uint256 currentIndex = 0;

        for(uint256 i=0; i< activequeue.length -1; i++){
            if((available[activequeue[i]] == true) && (Game(activequeue[i]).wages() == _wage)){
                availableList[currentIndex] = activequeue[i];
                currentIndex++;
            }
        }
        return availableList;
    }

    function joinGame(address _gameAdd, uint8[3] memory _choices) external activeUser{
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= Game(_gameAdd).wages(),"NEB"); //Not enough balance
        require(available[_gameAdd] == true,"NA");
        available[_gameAdd] = false;
        address winner = Game(_gameAdd).addPlayer2(msg.sender, _choices);
        address player1 =  Game(_gameAdd).player1();
        uint16 wage = Game(_gameAdd).wages();
        if(winner != address(0)){
            if(winner == msg.sender){
                IERC20(tokenAddress).transferFrom(player1, msg.sender, wage);
            }else {
                IERC20(tokenAddress).transferFrom(msg.sender, player1, wage);
            }
        }
    }

}