pragma solidity ^0.4.18;

import './math/SafeMath.sol';

// ERC20 token interface is implemented only partially.
// Token transferFrom is prohibited due to spec,
// hence some functions are left undefined:
//  - transferFrom, approve, allowance.

contract PrivatesaleToken {

    using SafeMath for uint;

    /// @dev Constructor
    /// @param _tokenManager Token manager address.
    function PrivatesaleToken(address _tokenManager, address _escrow) {
        tokenManager = _tokenManager;
        escrow = _escrow;
    }


    /*/
     *  Constants
    /*/

    string public constant name = "STRAT TOKEN Private Sale";
    string public constant symbol = "WSTR";
    uint   public constant decimals = 18;

    uint public constant PRICE = 4856; // 4856 WSTR per Ether

    //  price
    // 1 eth = 4856 presale tokens
    // ETH price ~777$

    uint public constant TOKEN_SUPPLY_LIMIT = 300000 * (1 ether / 1 wei);



    /*/
     *  Token state
    /*/

    enum Phase {
        Created,
        Running,
        Paused,
        Migrating,
        Migrated
    }

    Phase public currentPhase = Phase.Created;
    uint public totalSupply = 0; // amount of tokens already sold

    // Token manager has exclusive priveleges to call administrative
    // functions on this contract.
    address public tokenManager;

    // Gathered funds can be withdrawn only to escrow's address.
    address public escrow;

    uint public escrowBalance = 0;

    // Crowdsale manager has exclusive priveleges to burn presale tokens.
    address public crowdsaleManager;

    mapping (address => uint256) private balance;
    mapping(address => mapping(address => uint)) allowed;


    modifier onlyTokenManager()     { if(msg.sender != tokenManager) throw; _; }
    modifier onlyCrowdsaleManager() { if(msg.sender != crowdsaleManager) throw; _; }


    /*/
     *  Events
    /*/

    event LogBuy(address indexed owner, uint value);
    event LogBurn(address indexed owner, uint value);
    event LogPhaseSwitch(Phase newPhase);
    event Transfer(address indexed from, address indexed to, uint tokens);


    // Transfer the balance from owner's account to another account
    function transfer(address to, uint tokens) public returns (bool success) {
        require(to != address(0));
        require (to != 0x0);
        uint senderBalance = balance[msg.sender];
        if(senderBalance < tokens) throw;
        balance[msg.sender] = senderBalance.sub(tokens);
        balance[to] = balance[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


    /*/
     *  Public functions
    /*/

    function() payable {
        buyTokens(msg.sender);
    }

    /// @dev Lets buy you some tokens.
    function buyTokens(address _buyer) public payable {
        require(_buyer != address(0));
        require (_buyer != 0x0);
        // Available only if presale is running.
        if(currentPhase != Phase.Running) throw;

        if(msg.value == 0) throw;
        uint newTokens = msg.value.mul(PRICE);
        if (totalSupply.add(newTokens) > TOKEN_SUPPLY_LIMIT) throw;
        balance[_buyer] = balance[_buyer].add(newTokens);
        totalSupply = totalSupply.add(newTokens);
        transfer(_buyer, newTokens);
        //LogBuy(_buyer, newTokens);
    }


    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function burnTokens(address _owner) public
        onlyCrowdsaleManager
    {
        require(_owner != address(0));
        require (_owner != 0x0);
        // Available only during migration phase
        if(currentPhase != Phase.Migrating) throw;

        uint tokens = balance[_owner];
        if(tokens == 0) throw;
        balance[_owner] = 0;
        totalSupply = totalSupply.sub(tokens);
        LogBurn(_owner, tokens);

        // Automatically switch phase when migration is done.
        if(totalSupply == 0) {
            currentPhase = Phase.Migrated;
            LogPhaseSwitch(Phase.Migrated);
        }
    }


    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256) {
        return balance[_owner];
    }


    /*/
     *  Administrative functions
    /*/

    function setPresalePhase(Phase _nextPhase) public
        onlyTokenManager
    {
        bool canSwitchPhase
            =  (currentPhase == Phase.Created && _nextPhase == Phase.Running)
            || (currentPhase == Phase.Running && _nextPhase == Phase.Paused)
                // switch to migration phase only if crowdsale manager is set
            || ((currentPhase == Phase.Running || currentPhase == Phase.Paused)
                && _nextPhase == Phase.Migrating
                && crowdsaleManager != 0x0)
            || (currentPhase == Phase.Paused && _nextPhase == Phase.Running)
                // switch to migrated only if everyting is migrated
            || (currentPhase == Phase.Migrating && _nextPhase == Phase.Migrated
                && totalSupply == 0);

        if(!canSwitchPhase) throw;
        currentPhase = _nextPhase;
        LogPhaseSwitch(_nextPhase);
    }


    function withdrawEther() public
        onlyTokenManager
    {
        // Available at any phase.
        if(this.balance > 0) {
            if(!escrow.send(this.balance)) throw;
        }
    }

    function setEscrowBalance(uint tokens) public
        onlyTokenManager
    {
        if(tokens > 0 && escrowBalance == 0) {
            escrowBalance = tokens;
        } else {
            throw;
        }
    }


    function setCrowdsaleManager(address _mgr) public
        onlyTokenManager
    {
        // You can't change crowdsale contract when migration is in progress.
        if(currentPhase == Phase.Migrating) throw;
        crowdsaleManager = _mgr;
    }
}
