// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// error NotOwner();
error NotWinner();
error NotCreator();
error BalanceNotEnough();
error AlreadyInGame();
error CreatorCantJoin();
contract Quizy {

    address[] public players; //keep address amount of players.
    mapping(address => PlayerInfo) public allPlayers; //keep each PlayerInfo in array allPlayers.
    

    struct PlayerInfo {
        uint256 myscore;
        bool isPaid;
        uint256 currentQuestion; // the current question that they're doing.
    }

    QuestionDetail[] public allQuestions;

    struct QuestionDetail {
        string question;
        string correctAns;
    }

    // address public /* immutable */ i_owner;

    //Now we are suppose that quizcreator and the winner is the same address.
    // address public i_winner;
    address public i_quizCreator;
    

    constructor() {
        // i_quizCreator = msg.sender;
        i_quizCreator = msg.sender;

        
        // i_winner = msg.sender;
    }

    
    

    // modifier onlyWinner {
    //     //winner is the one that has highest score
    //     //you can be the winner if the quiz has end (run out of time or everyone submit the quiz)
    //     if (msg.sender != i_winner) revert NotWinner();
    //     _;
    // }

    modifier onlyQuizCreator {
        if (msg.sender != i_quizCreator) revert NotCreator();
        _;
    }
    

    string[] allQuest;
    string[] allAns;

    function getArrayPlayers() public view returns(address[] memory) {
        return players;
    }

    function retrieveAllQuestionAndAnswer() public returns(string[] memory, string[] memory) {
        // string[] memory allQuest;
        // string[] memory allAns;
        for(uint256 i = 0; i < allQuestions.length; i++) {
            allQuest.push(allQuestions[i].question);
            allAns.push(allQuestions[i].correctAns);
        } 
        return (allQuest, allAns);
    }

    function addQuiz(string memory _question, string memory _correctAns) public onlyQuizCreator {
        allQuestions.push(QuestionDetail(_question, _correctAns));
    }

    function quizSize() public view returns(uint256) {
        return allQuestions.length;
    }

    function lookQuizs(uint256 _num) public view returns(QuestionDetail memory) {
        return allQuestions[_num];
    }

    function getQuizCreator() public view returns(address) {
        return i_quizCreator;
    }


    // function letQuizs() public view {
    //     allPlayers[msg.sender].myscore;
    // }
    function getMyQuestion() public view returns(string memory) {
        uint256 num = allPlayers[msg.sender].currentQuestion;
        return allQuestions[num].question;
    }

    function doQuiz(string memory _ans) public {
        uint256 num = allPlayers[msg.sender].currentQuestion;
        if(compareStrings(allQuestions[num].correctAns, _ans)) {
            allPlayers[msg.sender].myscore++;
        }
        allPlayers[msg.sender].currentQuestion++; 
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

     function withdrawV2() public  {
        // for (uint256 playerIndex=0; playerIndex < players.length; playerIndex++){
        //     address x = players[playerIndex];
        //     // allPlayers[x].myfund = 0;
        //     allPlayers[x].myscore = 0;
        //     allPlayers[x].isPaid = false;
        //     allPlayers[x].currentQuestion = 0;

        // }
        // players = new address[](0);
        // arrWinner = new address[](0);

        
        // funders = new address[](0);
        // // transfer
        // payable(msg.sen der).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call

        //shareReward depend on the number of highest score.
        // uint shareReward = address(this).balance / arrWinner.length;
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
       
        
    }

    
    function joinQuiz() public payable { 
        // if (players.length == 0) {
        //     i_quizCreator = msg.sender;
        // }
        require(msg.sender != i_quizCreator, "creator cant join");
        if (msg.value < 1e16) revert BalanceNotEnough();
        // if (allPlayers[msg.sender].isPaid != true) revert AlreadyInGame();
        // require(msg.value > 1e15, "did not enough");
        require(allPlayers[msg.sender].isPaid != true, "you already regist");
        allPlayers[msg.sender].myscore = 0;
        allPlayers[msg.sender].isPaid = true;
        allPlayers[msg.sender].currentQuestion = 0;

        players.push(msg.sender);
    }

    function retrievePlayerSize() public view returns(uint256) {
        return players.length;
    }

    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }


    function getPlayerScore(address _address) public view 
    returns(
        uint256,
        uint256
         ) {
        return (
            allPlayers[_address].myscore,
            allPlayers[_address].currentQuestion
        );
    }

  

    address[] public arrWinner;
    function whoHighestScore() public returns(address[] memory){

        address current = players[0];
        for (uint256 i = 0; i < players.length-1; i++) {
                
                // current = players[i];
                address next = players[i+1];

                if(allPlayers[current].myscore < allPlayers[next].myscore) {
                    // highest = allPlayers[x].myscore
                    current = next;
                }
        }
        arrWinner.push(current);

        for(uint256 j = 0; j < players.length; j++) {
            if(allPlayers[current].myscore == allPlayers[players[j]].myscore) {
                if(current != players[j]) {
                    arrWinner.push(players[j]);
                }
            }
        }
        // return current;
        return arrWinner;

    }

    function withdraw() public onlyQuizCreator {
        for (uint256 playerIndex=0; playerIndex < players.length; playerIndex++){
            address x = players[playerIndex];
            // allPlayers[x].myfund = 0;
            allPlayers[x].myscore = 0;
            allPlayers[x].isPaid = false;
            allPlayers[x].currentQuestion = 0;

        }
        players = new address[](0);
        
        
        
        // funders = new address[](0);
        // // transfer
        // payable(msg.sen der).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call

        //shareReward depend on the number of highest score.
        // uint shareReward = address(this).balance / arrWinner.length;
        for(uint256 i = 0; i < arrWinner.length; i++) {
            (bool callSuccess, ) = payable(arrWinner[i]).call{value: address(this).balance/(arrWinner.length-i)}("");
            require(callSuccess, "Call failed");
        } 
        

        arrWinner = new address[](0);
    }



    fallback() external payable {
        joinQuiz();
    }

    receive() external payable {
        joinQuiz();
    }

    
}