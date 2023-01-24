// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface MeowToken {
    function totalSupply() external returns (uint);
    function balanceOf(address tokenOwner) external returns (uint balance);
    function allowance(address tokenOwner, address spender) external returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract CatFight {
    IERC721 NFTtoken;
    MeowToken meowtoken;
    event FinishedOneFight(address winner, uint256 roomnum);
    event EnterFirstroom(address enterer, uint256 roomnum);

    struct Roominfo {
        bool status;
        address[] fighters;
        uint256 random1;
        uint256 random2;
        uint256 tokenId1;
        uint256 tokenId2;
        uint256 value1;
        uint256 value2;
    }

    mapping(address => uint256) public stacked;
    mapping(uint256 => Roominfo) public roominfo;

    uint256 public maxroomnum;
    uint256 public income;
    uint256 public current;
    uint256 public meowbalance;
    uint256 public totalStaked;

    address public nfttokenaddress = 
        0xA3D40B9be89e1074309Ed8EFf9F3215F323C8b19;
    address public meowaddress = 
        0xA5E414c34B85f0591925eCe147E9353F684a2918;
    address private _owner;

    constructor() {
        NFTtoken = IERC721(nfttokenaddress);
        meowtoken = MeowToken(meowaddress);
        _owner = msg.sender;
        totalStaked = 0;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function deposit(uint256 _amount) public onlyOwner {
        meowtoken.transferFrom(msg.sender, address(this), _amount);
    }

    function enterroom(uint256 _roomnum, uint256 _tokenId) public payable {
        require(NFTtoken.ownerOf(_tokenId) == msg.sender, "Not your NFT!");
        require(NFTtoken.getApproved(_tokenId) == address(this), "Token cannot be transfered");
        require(msg.value >= 10, "Not enough balance!");
        require(_roomnum > maxroomnum, "Create another room!");
        maxroomnum = _roomnum;
        roominfo[_roomnum] = Roominfo({
            status: false,
            fighters: new address[](0),
            random1 : 0,
            random2 : 0,
            tokenId1 : 0,
            tokenId2 : 0,
            value1: 0,
            value2: 0
        });
        roominfo[_roomnum].fighters.push(msg.sender);
        roominfo[_roomnum].random1 = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 100000) + 1;
        roominfo[_roomnum].tokenId1 = _tokenId;
        roominfo[_roomnum].value1 = msg.value;
        NFTtoken.transferFrom(msg.sender, address(this), _tokenId);
    }

    function fight(uint256 _roomnum, uint256 _tokenId) public payable {
        require(NFTtoken.ownerOf(_tokenId) == msg.sender, "Not your NFT!");
        require(NFTtoken.getApproved(_tokenId) == address(this), "Token cannot be transfered");
        require(msg.value >= 10, "Not enough balance!");
        require(
            roominfo[_roomnum].status != true,
            "Game is already finished!"
        );
        require(
            roominfo[_roomnum].fighters.length != 2,
            "Not enough players!"
        );
        roominfo[_roomnum].fighters.push(msg.sender);
        require(
            roominfo[_roomnum].fighters.length == 2,
            "Too many or less players!"
        );
        roominfo[_roomnum].random2 = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 100000) + 1;
        roominfo[_roomnum].tokenId2 = _tokenId;
        roominfo[_roomnum].value2 = msg.value;
        NFTtoken.transferFrom(msg.sender, address(this), _tokenId);
        if(roominfo[_roomnum].random1 > roominfo[_roomnum].random2) {
            NFTtoken.transferFrom(address(this), roominfo[_roomnum].fighters[0], roominfo[_roomnum].tokenId1);
            NFTtoken.transferFrom(address(this), roominfo[_roomnum].fighters[0], roominfo[_roomnum].tokenId2);
            payable(roominfo[_roomnum].fighters[0]).transfer(20);
            meowtoken.transfer(roominfo[_roomnum].fighters[0], 20000000000);
            meowtoken.transfer(roominfo[_roomnum].fighters[1], 20000000000);
        }
        else {
            NFTtoken.transferFrom(address(this), roominfo[_roomnum].fighters[1], roominfo[_roomnum].tokenId1);
            NFTtoken.transferFrom(address(this), roominfo[_roomnum].fighters[1], roominfo[_roomnum].tokenId2);
            payable(roominfo[_roomnum].fighters[1]).transfer(20);
            meowtoken.transfer(roominfo[_roomnum].fighters[0], 20000000000);
            meowtoken.transfer(roominfo[_roomnum].fighters[1], 20000000000);
        }
    }

    function stacking(uint256 _amount) public {

    }
}