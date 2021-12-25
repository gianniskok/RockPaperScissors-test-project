//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Game {
    address public immutable player1;
    address player2 = address(0);
    uint16 immutable public wages;
    uint8[6] public choices;
    address public winner;

    //Best Of Three
    //0 == ROCK, 1 == PAPER, 2 == SCISSORS
    
    constructor(address _player1, uint16 _wages, uint8[3] memory _choices){
        player1 = _player1;
        wages = _wages;
        choices = _choices;
    }

    function addPlayer2(address _player2, uint8[3] memory _choices) external returns (address){
        for(uint8 i=0; i<3 ;i++){
            choices[i+3] = _choices[i];
        }
        player2 = _player2;
        return startGame();
    }

    function startGame() internal view returns (address) {
        require(player2 != address(0));
        uint8 p1Rounds = 0;
        uint8 p2Rounds = 0;

        for (uint8 i=0; i<3 ; i++){
            if((choices[i] == 0 && choices[i+3] == 2) || (choices[i] == 1 && choices[i+3] == 0) || (choices[i] == 2 && choices[i+3] == 1)){ //player1wins
                p1Rounds++;
            }
            else if((choices[i] == 0 && choices[i+3] == 1) || (choices[i] == 1 && choices[i+3] == 2) || (choices[i] == 2 && choices[i+3] == 0)){ //player2 wins
                p2Rounds++;
            }
        }

        if((p1Rounds >= 2) || ((p1Rounds == 1) && p2Rounds < 1) ){
            return player1;
        }else if(p2Rounds>= 2 || ((p2Rounds == 1) && p1Rounds < 1)){
            return  player2;
        }else {
            return address(0);
        }
    }
}
