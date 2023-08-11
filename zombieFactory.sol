pragma solidity ^0.5.12;

import "./ownable.sol";
import "./safemath.sol";

contract ZombieFactory is Ownable{
    // 引用安全数学防止溢出
    using SafeMath for uint256;
    
    uint dnaDigits = 16;  // 基因位数
    uint dnaModulus = 10 ** dnaDigits;  // 基因单位
    uint public cooldownTime = 1 days;  // 自动转换为秒
    uint public zombiePrice = 0.01 ether; // 自动转换最小单位wei
    uint public zombieCount = 0; // 初始僵尸总数

    // // 僵尸类
    struct Zombie{
        string name;
        uint dna;
        uint16 winCount;
        uint16 lossCount;
        uint32 level;
        uint32 readyTime; 
    }

    Zombie[] public zombies; // 僵尸数组

    mapping (uint=>address) public zombieToOwner;  // 僵尸id=>拥有者
    mapping (address=>uint) ownerZombieCount;  // 拥有者=>僵尸数量
    mapping (uint=>uint) public  zombieFeedTimes;  // 僵尸为食次数

    event NewZombie(uint zombieId,string _name,uint dna);

    function createZombie(string memory _name) public{
        // 验证发送者将是数量为0
        require(ownerZombieCount[msg.sender]==0);  // msg.sender获取发送者位置
        uint randDna =  uint(uint(keccak256(abi.encodePacked(_name,now))) % dnaModulus);  // 根据名称获取随机数dna
        randDna = randDna - randDna % 10;
        uint id = zombies.push(Zombie(_name, randDna, 0, 0, 1, 0)) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        zombieCount = zombieCount.add(1);
        emit NewZombie(id,_name,randDna); //通知
    }
}