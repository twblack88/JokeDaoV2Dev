// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (governance/IGovernor.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/ERC165.sol";

/**
 * @dev Interface of the {Governor} core.
 *
 * _Available since v4.3._
 */
abstract contract IGovernor is IERC165 {
    enum ContestState {
        Active,
        Canceled,
        Queued,
        Completed
    }

    /**
     * @dev Emitted when a proposal is created.
     */
    event ProposalCreated(
        uint256 proposalId,
        string description,
        address proposer
    );

    /**
     * @dev Emitted when proposals are deleted.
     */
    event ProposalsDeleted(
        uint256[] proposalIds
    );

    /**
     * @dev Emitted when a contest is canceled.
     */
    event ContestCanceled();

    /**
     * @dev Emitted when a vote is cast.
     *
     * Note: `support` values should be seen as buckets. There interpretation depends on the voting module used.
     */
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 numVotes, string reason);

    /**
     * @notice module:core
     * @dev Name of the governor instance (used in building the ERC712 domain separator).
     */
    function name() public view virtual returns (string memory);

    /**
     * @notice module:core
     * @dev Prompt of the governor instance (used in building the ERC712 domain separator).
     */
    function prompt() public view virtual returns (string memory);

    /**
     * @notice module:core
     * @dev Version of the governor instance (used in building the ERC712 domain separator). Default: "1"
     */
    function version() public view virtual returns (string memory);

    /**
     * @notice module:voting
     * @dev A description of the possible `support` values for {castVote} and the way these votes are counted, meant to
     * be consumed by UIs to show correct vote options and interpret the results. The string is a URL-encoded sequence of
     * key-value pairs that each describe one aspect, for example `support=bravo&quorum=for,abstain`.
     *
     * There are 2 standard keys: `support` and `quorum`.
     *
     * - `support=bravo` refers to the vote options 0 = Against, 1 = For, 2 = Abstain, as in `GovernorBravo`.
     * - `quorum=bravo` means that only For votes are counted towards quorum.
     * - `quorum=for,abstain` means that both For and Abstain votes are counted towards quorum.
     *
     * NOTE: The string can be decoded by the standard
     * https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams[`URLSearchParams`]
     * JavaScript class.
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual returns (string memory);

    /**
     * @notice module:core
     * @dev Hashing function used to (re)build the proposal id from the proposal details..
     */
    function hashProposal(
        string memory proposalDescription
    ) public pure virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Current state of a Contest, following Compound's convention
     */
    function state() public view virtual returns (ContestState);

    /**
     * @notice module:core
     * @dev Timestamp the contest started at.
     */
    function contestStart() public view virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Timestamp the contest vote begins.
     */
    function voteStart() public view virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Timestamp at which votes close. Votes close at the end of this block, so it is possible to cast a vote
     * during this block.
     */
    function contestDeadline() public view virtual returns (uint256);

    /**
     * @notice module:user-config
     * @dev Delay, in seconds, between the proposal is created and the vote starts. This can be increassed to
     * leave time for users to buy voting power, of delegate it, before the voting of a proposal starts.
     */
    function votingDelay() public view virtual returns (uint256);

    /**
     * @notice module:user-config
     * @dev Delay, in seconds, between the vote start and vote ends.
     *
     * NOTE: The {votingDelay} can delay the start of the vote. This must be considered when setting the voting
     * duration compared to the voting delay.
     */
    function votingPeriod() public view virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Timestamp used to retrieve user's votes and quorum. As per Compound's Comp and OpenZeppelin's
     * ERC20Votes, the snapshot is performed at the end of this block with this timestamp. Hence, voting for this proposal starts at the
     * beginning of the following block.
     */
    function contestSnapshot() public view virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Creator of the contest, has the power to cancel the contest and delete proposals in it.
     */
    function creator() public view virtual returns (address);

    /**
     * @notice module:reputation
     * @dev Voting power of an `account` at a specific `timestamp`.
     *
     * Note: this can be implemented in a number of ways, for example by reading the delegated balance from one (or
     * multiple), {ERC20Votes} tokens.
     */
    function getVotes(address account, uint256 timestamp) public view virtual returns (uint256);

    /**
     * @notice module:reputation
     * @dev Voting power of an `account` at the current block.
     *
     * Note: this can be implemented in a number of ways, for example by reading the delegated balance from one (or
     * multiple), {ERC20Votes} tokens.
     */
    function getCurrentVotes(address account) public view virtual returns (uint256);

    /**
     * @notice module:reputation
     * @dev Voting power of an `account` at the current block for a token for submission gating.
     *
     * Note: this can be implemented in a number of ways, for example by reading the delegated balance from one (or
     * multiple), {ERC20Votes} tokens.
     */
    function getCurrentSubmissionTokenVotes(address account) public view virtual returns (uint256);

    /**
     * @dev Create a new proposal. Vote start {IGovernor-votingDelay} blocks after the proposal is created and ends
     * {IGovernor-votingPeriod} blocks after the voting starts.
     *
     * Emits a {ProposalCreated} event.
     */
    function propose(
        string memory proposalDescription
    ) public virtual returns (uint256 proposalId);

    /**
     * @dev Cast a vote
     *
     * Emits a {VoteCast} event.
     */
    function castVote(uint256 proposalId, uint8 support, uint256 numVotes) public virtual returns (uint256 balance);

    /**
     * @dev Cast a vote with a reason
     *
     * Emits a {VoteCast} event.
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        uint256 numVotes,
        string calldata reason
    ) public virtual returns (uint256 balance);

    /**
     * @dev Cast a vote using the user cryptographic signature.
     *
     * Emits a {VoteCast} event.
     */
    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint256 numVotes,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual returns (uint256 balance);
}
