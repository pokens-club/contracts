// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

// This contract allows beta testers to register for the PokENS beta testing rounds.
// Created within the context of tracking beta tester rewards for participating in beta.
// Developed by ho-oh.eth

contract PokENS_Beta_Signup is Ownable {

    // Starting $POKENS reward = 69,420
    // Bonus $POKENS reward lowers by 5% for each new beta tester added until reward reaches < 1
    bool public betaOpen = false;
    uint256 public currentBonusReward = 69420;
    uint256 masterKey = 0;

    struct BetaTester {
        string favMon;          // Favorite Pokémon
        uint reward;            // Bonus reward for tester
        bool active;            // Is tester registered?
        bool participant;       // Did tester participate?
        uint256 rounds;         // How many rounds?
    }

    mapping(address => BetaTester) public betaTester;       // Can check the status of a specific tester here
    address[] public betaTesterIds;                         // Can check the addresses of testers here

    // Can register for beta until full, then registering becomes locked
    function registerForBeta(string memory favMon) public {
        require(currentBonusReward >= 1, "Sorry, this round of beta testing is full");
        require(betaTester[msg.sender].active != true, "Tester already registered");
        betaTesterIds.push(msg.sender);
        BetaTester storage newTester = betaTester[msg.sender];
        newTester.active = true;
        newTester.participant = false;
        newTester.rounds = 0;
        newTester.favMon = favMon;
        newTester.reward = currentBonusReward;
        currentBonusReward = currentBonusReward - (currentBonusReward / 20);        
    }

    // Will get participant key from beta testing logins
    function addParticipant(uint256 participantKey) public {
        require(betaOpen == true, "Beta testing is not open");
        require(masterKey != 0 && masterKey == participantKey, "Keys do not match! ...I smell funny business.");
        require(betaTester[msg.sender].active == true, "Tester must be registered for beta");
        require(betaTester[msg.sender].participant != true, "Participation is already confirmed");
        BetaTester storage newTester = betaTester[msg.sender];
        newTester.participant = true;
        newTester.rounds++;
    }

    // See how many testers have signed up
    function getNumTesters() public view returns (uint256) {
        uint256 num = betaTesterIds.length;
        return num;
    }

    // Game master to set beta to open and master key for each round of beta.
    function setMasterKey(uint256 _masterKey, bool _openStatus) public onlyOwner {
        masterKey = _masterKey;
        betaOpen = _openStatus;
    }

}
