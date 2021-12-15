//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

contract Users{
    using Counters for Counters.Counter;
    Counters.Counter _newUserId;

    address immutable owner;
    
    constructor(){
        owner = msg.sender;
    }

    struct User {
        uint256 id;
        uint8 credibility;
        address userAd;
        string userName;
        bool isActive;
    }

    User[] newUser;
    mapping(address => uint256) addToUser;
    mapping(address => bool) isUser;
    mapping(address => uint256) addressToTimestamp;

    modifier onlyOwner{
        require(msg.sender == owner, "NO"); //Not owner
        _;
    }

    modifier notUser{
        require(isUser[msg.sender] != true, "AU");//Already User
        _;
    }

    modifier activeUser{
        require(newUser[addToUser[msg.sender]].isActive == true, "NA"); //Not active 
        _;
    }

    modifier userExists{
        require (isUser[msg.sender] == true,"NU"); //Not user
        _;
    }

    function createUser(string memory _userName) external notUser {
        User memory userInstance;
        userInstance.id = _newUserId.current();
        userInstance.userAd = msg.sender;
        userInstance.credibility = 100;
        userInstance.userName = _userName;
        userInstance.isActive = true;
        addToUser[msg.sender] = _newUserId.current();
        newUser.push(userInstance);
        _newUserId.increment();
    }

    function discipline(address _userAd) internal {
        require( newUser[addToUser[_userAd]].isActive == true,"NA");
        newUser[addToUser[_userAd]].credibility -= 5;
        
        if(newUser[addToUser[_userAd]].credibility <= 20){
            newUser[addToUser[_userAd]].isActive = false;
            addressToTimestamp[_userAd] = block.timestamp;
        }
    }

    function reActivate(address _userAd) internal {
        require(addressToTimestamp[_userAd] + 3600 * 24 * 10 <= block.timestamp);
        newUser[addToUser[_userAd]].isActive = true;
        newUser[addToUser[_userAd]].credibility = 50;
    }

}