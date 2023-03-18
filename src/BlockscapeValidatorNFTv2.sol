// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
//import "openzeppelin-contracts/access/Ownable.sol"; replaced by: AccessControl
import "openzeppelin-contracts/access/AccessControl.sol";

import "openzeppelin-contracts/utils/Address.sol";

import "openzeppelin-contracts/utils/Strings.sol";
import "./utils/RocketStorageInterface.sol";
import "./utils/RocketNodeStakingInterface.sol";

/** 
    @title Rocketpool Staking Allocation Contract
    @author Blockscape Finance AG <info@blockscape.network>
    @notice collects staking, mints NFT in return for staker and let's backend controller 
    transfer the stake when the pool is full (currently 16 ETH) and enough RPL are available
*/
contract BlockscapeValidatorNFT is
    ERC1155Supply,
    ReentrancyGuard,
    AccessControl
{
    using Address for address payable;

    /// @dev role to adjust the config of the smart contract
    bytes32 public constant ADJ_CONFIG_ROLE = keccak256("ADJ_CONFIG_ROLE");

    /// @dev role for the backendController identity
    bytes32 public constant RP_BACKEND_ROLE = keccak256("RP_BACKEND_ROLE");

    /// @dev role for the admin identity
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @dev RocketStorageInterface of rocketpool
    RocketStorageInterface constant ROCKET_STORAGE =
        RocketStorageInterface(0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46); // mainnet: 0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46 // goerli :0xd8Cd47263414aFEca62d6e2a3917d6600abDceB3

    /// @dev this is a given way to always retrieve the most up-to-date node address
    address rocketNodeStakingAddress =
        ROCKET_STORAGE.getAddress(
            keccak256(abi.encodePacked("contract.address", "rocketNodeStaking"))
        );
    /// @dev rocketpool contract interface for interactions
    RocketNodeStakingInterface rocketNodeStaking =
        RocketNodeStakingInterface(rocketNodeStakingAddress);

    /// @notice Admin Address
    address public admin = 0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982; //0xB467959ADFc3fA8d99470eC12F4c95aa4D9b59e5;

    /// @notice Blockscape Rocket Pool Node Address
    address payable public blockscapeRocketPoolNode =
        payable(0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982); //0xB467959ADFc3fA8d99470eC12F4c95aa4D9b59e5;

    /// @notice Current inital Withdraw Fee
    uint256 public initWithdrawFee = 20 * 1e18;

    /// @notice Current Rocketpool Minipool Limit
    uint256 public curETHlimit = 16 ether;

    /**
        @notice state of the Solo Vault Pool
        @dev is `false` when validator is currently onboarding, will be reopened, as soon as 
        the backend controller withdraws & transfers the stake
    */
    bool public allowPubDeposit;

    /** 
        @notice initial tokenID
        @dev the tokenID is the same as the tokenID of the validator
    */
    uint256 public tokenID = 1000;

    /** 
        @notice array for storing the Validator Public Keys
        @dev the index is the tokenID of the NFT mapping to the validator public key
    */

    /// @dev Metadata struct
    struct Metadata {
        uint256 stakedETH;
        uint256 stakedTimestamp;
    }

    /// @dev Mappings of tokenID to Metadata
    mapping(uint256 => Metadata) public tokenIDtoMetadata;

    /// @dev Mappings of tokenID to Validator public key
    mapping(uint256 => bytes) public tokenIDtoValidator;

    /// @dev event for when a batch is tried to withdrawn but not enough rpl
    /// are available yet
    event RPLStakeRequired(uint256 _availRPL, uint256 _requiredRPL);

    /// @dev event for when a user requests a withdrawal
    event UserRequestedWithdrawal(
        uint256 _tokenID,
        address _user,
        uint256 _fee,
        uint256 _stakedETH
    );

    /// @dev event for when the ETH limit is changed
    event ETHLimitChanged(uint256 _newLimit);

    /// @dev event for when the RocketPool Node Address is changed
    event RocketPoolNodeAddressChanged(address _newAddress);

    /// @dev more RPL stake has to be done in order to open vault
    error NotEnoughRPLStake();

    /** 
        @notice each validator related vault gets its separate tokenID which depicts 
        the nft for each staker
        @dev the IPNS makes sure the nfts stay reachable via this link while 
        new nfts get added to the underlying ipfs folder
     */
    constructor()
        ERC1155(
            "https://ipfs.blockscape.network/ipns/"
            "k51qzi5uqu5di5eo5fzr1zypdsz0zct39zpct9s4wesjustul1caeofak3zoej/"
            "{id}.json"
        )
    {
        _grantRole(ADJ_CONFIG_ROLE, msg.sender);
        _grantRole(RP_BACKEND_ROLE, blockscapeRocketPoolNode);
        _grantRole(ADMIN_ROLE, admin);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // functions

    // public & external functions

    /// @notice makes the vault stakable again after it has been closed
    /// @dev is triggered when the vault can be staked at rocketpool
    function openValidatorNFT() public onlyRole(RP_BACKEND_ROLE) {
        if (!hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        assembly {
            if sload(allowPubDeposit.slot) {
                revert(0, 0)
            }
            sstore(allowPubDeposit.slot, 1)
        }
    }

    /**
        @notice withdraw the given amount to the deployer, triggered when the 
        the backend controller moves the stake to rocketpool
        @dev the withdraw function remains public as safety measurement to
        not lock-in client stakes in case of contract issues
        @param _amount the amount in wei to withdraw
     */
    // function withdraw(uint256 _amount) public onlyRole(ADMIN_ROLE) {
    //     payable(owner()).transfer(_amount);
    // }

    /**
        @notice is triggered when the vault can be staked at rocketpool
        @dev future staking interactions are prevented afterwards
     */
    function closeValidatorNFT() external onlyRole(RP_BACKEND_ROLE) {
        assembly {
            sstore(allowPubDeposit.slot, 0)
        }
    }

    /// @notice used when staking eth into the contract
    /// @dev the vault must be open and equal the depositing amount
    function depositValidatorNFT() external payable {
        if (!hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        if (_compareBytes(tokenIDtoValidator[tokenID], bytes(""))) {
            revert();
        }

        assembly {
            // load the curETHlimit from storage
            let cel := sload(curETHlimit.slot)

            // check if the vault is open
            if iszero(sload(allowPubDeposit.slot)) {
                revert(0, 0)
            }

            // check if the deposit is valid (like the current RP ETH limit 16ETH/8ETH)
            if iszero(eq(callvalue(), cel)) {
                revert(0, 0)
            }
        }

        // create metadata for the new tokenID
        _metadataValidatorNFTInternal(msg.value, tokenID);

        assembly {
            // increase the tokenID
            let tokenID_value := sload(tokenID.slot)
            let new_tokenID_value := add(tokenID_value, 1)
            sstore(tokenID.slot, new_tokenID_value)
        }

        // close the vault
        _closeValidatorNFTInternal();
    }

    /**
        @notice this gets triggered by the backend controller when the vault 
        is closed
     */
    function withdrawBatch() external onlyRole(RP_BACKEND_ROLE) {
        assembly {
            // check if the vault is closed
            if sload(allowPubDeposit.slot) {
                revert(0, 0)
            }
        }

        Address.sendValue(blockscapeRocketPoolNode, curETHlimit);
    }

    /**
        @notice used when user wants to unstake
        @param _tokenID which validator NFT the staker wants to unstake; the backend will listen on the event and will unstake the validator. The ETH value with rewards is transparantly available via beacon chain explorers and will be reduced by the withdraw fee, which is fixed to 0.5% after one year.
     */
    function startRequestWithdrawProcess(
        uint256 _tokenID,
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        uint256 curWithdrawFee = calcWithdrawFee(_tokenID, msg.sender);
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, _hashedMessage)
        );
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);

        if (balanceOf(msg.sender, _tokenID) >= 1 && signer == msg.sender) {
            emit UserRequestedWithdrawal(
                _tokenID,
                msg.sender,
                curWithdrawFee,
                tokenIDtoMetadata[_tokenID].stakedETH
            );
        }
    }

    // functions for future maintainability

    /**
        @notice the limit might change in the future if rocketpool supports 
        smaller pool sizes (RPIP-8)
        @param _newLimit the new pool amount which has to be staked
    */
    function changeETHLimit(
        uint256 _newLimit
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        curETHlimit = _newLimit;
        emit ETHLimitChanged(_newLimit);
    }

    /**
        @notice the withdraw fee might be changed in the future
        @param _amount the new fee in wei
     */
    function setWithdrawFee(
        uint256 _amount
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        initWithdrawFee = _amount;
    }

    /**
        @notice gets used if rocketpool changes the address of their node
        @param _newBlockscapeRocketPoolNode the new address of the rocketpool node
     */
    function setBlockscapeRocketPoolNode(
        address _newBlockscapeRocketPoolNode
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        blockscapeRocketPoolNode = payable(_newBlockscapeRocketPoolNode);
        emit RocketPoolNodeAddressChanged(_newBlockscapeRocketPoolNode);
    }

    // add new validator public keys to the tokenIDtoValidator mapping
    function addValidatorPublicKeys(
        bytes[] memory _newValidatorPubKeys
    ) external onlyRole(ADMIN_ROLE) {
        for (uint i = 0; i < _newValidatorPubKeys.length; i++) {
            tokenIDtoValidator[tokenID + 1 + i] = _newValidatorPubKeys[i];
        }
    }

    // view / pure functions

    /** 
        @notice does the vault currently allow depositing
        @dev the backend controller will reopen then vault after the stake
        have been transferred
        @return is depositing enabled
    */
    function isVaultOpen() public view returns (bool) {
        return allowPubDeposit;
    }

    /**
        @notice the current depositing threshold
        @return is depositing enabled
    */
    function getCurrentEthLimit() public view returns (uint256) {
        return curETHlimit;
    }

    /**
        @notice show the currently available RPL stake which is needed to create 
        a pool on rocketscape
        @return the current available RPL stake with already deducted minimum
        stake
     */
    function getAvailableRPLStake() public view returns (uint256) {
        uint256 nodeRPLStake = rocketNodeStaking.getNodeRPLStake(
            blockscapeRocketPoolNode
        );

        return nodeRPLStake;
    }

    /**
        @notice calculates the required RPL needed to stake according to 
        poolsize
        @dev if the minipoollimit is `0` then the required stake is also `0`!
        @return the RPLs needed
     */
    function getReqRPLStake() public view returns (uint256) {
        uint256 minipoolLimit = rocketNodeStaking.getNodeMinipoolLimit(
            blockscapeRocketPoolNode
        );

        uint256 minimumRPLStake = rocketNodeStaking.getNodeMinimumRPLStake(
            blockscapeRocketPoolNode
        );

        if (minipoolLimit == 0) {
            return 0;
        }

        return (minimumRPLStake / minipoolLimit);
    }

    /// @notice has the node enough RPL to stake another minipool
    function hasNodeEnoughRPLStake() public view returns (bool) {
        uint256 minipoolLimit = rocketNodeStaking.getNodeMinipoolLimit(
            blockscapeRocketPoolNode
        );
        if (minipoolLimit == 0) {
            return false;
        }

        uint256 nodeRPLStake = rocketNodeStaking.getNodeRPLStake(
            blockscapeRocketPoolNode
        );
        uint256 minimumReqRPL = getReqRPLStake();

        return (nodeRPLStake - minimumReqRPL) >= 0;
    }

    /**
        @notice how much fees would the user has to pay if he would unstake now
        within the first year of staking the fee is starting at 20% & decreasing linearly, afterwards 0.5%
        @param _tokenID which pool the staker wants to unstake
        @return _amount how much the user would pay on fees
     */
    function calcWithdrawFee(
        uint256 _tokenID,
        address _user
    ) public view returns (uint256 _amount) {
        uint256 curWithdrawFee = initWithdrawFee;

        if (balanceOf(_user, _tokenID) >= 1) {
            uint256 secFee = (initWithdrawFee / 365 days); // 20%
            uint256 timePassed = block.timestamp -
                (tokenIDtoMetadata[_tokenID].stakedTimestamp);

            uint256 maxTime05EthReached = 30747600;
            if (timePassed >= maxTime05EthReached) {
                curWithdrawFee = 5 * 1e17; // fixed minimum fee 0,5 ether
            } else {
                curWithdrawFee = (initWithdrawFee - (secFee * timePassed));
            }
        }
        return curWithdrawFee;
    }

    /**
        @notice gets the metadata of a given pool
        @param _tokenID identifies the pool
        @return Metadata of the pool 
        @return the validator address
     */
    function getMetadata(
        uint256 _tokenID
    ) external view returns (Metadata memory, bytes memory) {
        return (
            tokenIDtoMetadata[_tokenID],
            // tokenIDtoStaker[_tokenID],
            tokenIDtoValidator[_tokenID]
        );
    }

    /**
        @notice the tokenID is incremented with every pool
        @return the current tokenID 
     */
    function getTokenID() public view returns (uint256) {
        return tokenID;
    }

    /**
        @notice how much balance does this vault current have
        @return amount in wei
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice how many staker are there totally
    /// @return total amount of staker
    function totalSupply() external view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = 1; i <= getTokenID(); i++) {
            amount += totalSupply(i);
        }
        return amount;
    }

    /** 
        @notice stake nft metdata location
        @dev this path will never change as the contract defines a collection
        @return the fixed collection metadata path 
     */
    function contractURI() external pure returns (string memory) {
        return
            "https://ipfs.blockscape.network/ipfs/QmUr8P96kNuFjcZb2WBjBP4e1fiGGXwRGChfTi42pnujY7";
    }

    /**
        @notice gets the url to the metadata of a given pool
        @param _tokenID the pool
        @return the url
     */
    function uri(
        uint256 _tokenID
    ) public pure override returns (string memory) {
        return
            string.concat(
                "https://ipfs.blockscape.network/ipns/k51qzi5uqu5di5eo5fzr1zypdsz0zct39zpct9s4wesjustul1caeofak3zoej/",
                Strings.toString(_tokenID),
                ".json"
            );
    }

    // internal functions

    /**
        @notice creates and mints metadata for a given pool and staker
        @param _stakedETH staked amount from the sender
        @param _tokenID Identifier of the vault
    */
    function _metadataValidatorNFTInternal(
        uint256 _stakedETH,
        uint256 _tokenID
    ) internal {
        Metadata memory metadata;

        metadata.stakedETH = _stakedETH;
        metadata.stakedTimestamp = block.timestamp;

        tokenIDtoMetadata[_tokenID] = metadata;

        _mint(msg.sender, _tokenID, 1, "");
    }

    /// @notice closes the vault to temporarily prevent further depositing
    function _closeValidatorNFTInternal() internal {
        assembly {
            sstore(allowPubDeposit.slot, 0)
        }
    }

    /**
        @notice compares two values and checks if there are equal
        @dev hashes the stringified values and compares those hashes
        @return are the bytes equal
     */
    function _compareBytes(
        bytes memory a,
        bytes memory b
    ) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function name() public pure returns (string memory) {
        return "Blockscape Validator NFTs";
    }

    /**
     * @return symbol of the ERC-1155 token
     */
    function symbol() public pure returns (string memory) {
        return "BSV";
    }
}
