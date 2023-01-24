// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract AngryRabbits is VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event FinishedOneFight(address winner, uint256 roundnum);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    struct Roominfo {
        bool status;
        address[] fighters;
        uint256[] randoms;
    }

    mapping(address => uint256) public reward;
    mapping(uint256 => Roominfo) public roominfo;
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    uint256 public firstrandom;
    uint256 public secondrandom;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint256 public maxroomnum;

    bytes32 keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 2;

    constructor()
        VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
        );
        s_subscriptionId = 8693;
        maxroomnum = 0;
    }

    function requestRandomWords()
        public
        returns (uint256 requestId)
    {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) public view returns (uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.randomWords);
    }

    function bet(uint256 _roomnum) public {
        if(_roomnum > maxroomnum) {
            maxroomnum = _roomnum;
            roominfo[_roomnum] = Roominfo({
                status: false,
                randoms: new uint256[](0),
                fighters: new address[](0)
            });
        }
        require(roominfo[_roomnum].status != true, "This betting game is already finished!");
        require(roominfo[_roomnum].fighters.length != 2, "There are already enough players!");
        roominfo[_roomnum].fighters.push(msg.sender);
        require(roominfo[_roomnum].fighters.length == 2, "There aren't enough players!");
        lastRequestId = requestRandomWords();
        roominfo[_roomnum].randoms = getRequestStatus(lastRequestId);
        firstrandom = (roominfo[_roomnum].randoms[0]) % 100000 + 1;
        secondrandom = (roominfo[_roomnum].randoms[1]) % 100000 + 1;
        reward[roominfo[_roomnum].fighters[0]] = 0;
        reward[roominfo[_roomnum].fighters[1]] = 0;
        if(firstrandom > secondrandom) {
            reward[roominfo[_roomnum].fighters[0]] += 20;
        } else {
            reward[roominfo[_roomnum].fighters[1]] += 20;
        }
        roominfo[_roomnum].status = true;
        emit FinishedOneFight(roominfo[_roomnum].fighters[0], _roomnum);
    }
}