pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface TimelockInterface {
    function delay() external view returns (uint);
    function GRACE_PERIOD() external view returns (uint);
    function acceptAdmin() external;
    function queuedTransactions(bytes32 hash) external view returns (bool);
    function queueTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external returns (bytes32);
    function cancelTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external;
    function executeTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external payable returns (bytes memory);
}

interface TokenInterface {
    function getPriorVotes(address account, uint blockNumber) external view returns (uint96);
}

contract TokenEvents {
    
    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /// @notice An event thats emitted when the minter changes
    event MinterChanged(address indexed oldMinter, address indexed newMinter);

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// @notice Emitted when implementation is changed
    event NewImplementation(address oldImplementation, address newImplementation);

    /// @notice An event thats emitted when the token transfered is paused
    event TransferPaused(address minter);

    /// @notice An event thats emitted when the token transfered is unpaused
    event TransferUnpaused(address minter);
}

contract TokenDelegatorStorage {
    /// @notice Administrator Token minter
    address public minter;

    /// @notice Active brains of Token
    address public implementation;

    /// @notice The timestamp after which implementation maybe change
    uint public changeImplementationAfter;

}

/**
 * @title Storage for Token Delegate
 * @notice For future upgrades, do not change TokenDelegateStorageV1. Create a new
 * contract which implements TokenDelegateStorageV1 and following the naming convention
 * TokenDelegateStorageVX.
 */
contract TokenDelegateStorageV1 is TokenDelegatorStorage {
    /// @notice EIP-20 token name for this token
    string public name = "<Token Name>"; // TODO - Replace it

    /// @notice EIP-20 token symbol for this token
    string public symbol = "<TKN>"; // TODO - Replace it

    /// @notice Total number of tokens in circulation
    uint public totalSupply = 10000000e18; // TODO - Replace it

    /// @notice The timestamp after which minting may occur
    uint public mintingAllowedAfter;

    // Allowance amounts on behalf of others
    mapping (address => mapping (address => uint96)) internal allowances;

    // Official record of token balances for each account
    mapping (address => uint96) internal balances;

    /// @notice A record of each accounts delegate
    mapping (address => address) public delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    /// @notice token transfer pause state
    bool public transferPaused;
}