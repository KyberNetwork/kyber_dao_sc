pragma solidity 0.6.6;

import "@kyber.network/utils-sc/contracts/Utils.sol";
import "../IKyberNetworkProxy.sol";
import "../IKyberFeeHandler.sol";

/// @dev contract to call trade when claimPlatformFee
contract ReentrancyFeeClaimer is Utils {
    IKyberNetworkProxy kyberProxy;
    IKyberFeeHandler feeHandler;
    IERC20Ext token;
    uint256 amount;

    bool isReentrancy = true;

    constructor(
        IKyberNetworkProxy _kyberProxy,
        IKyberFeeHandler _feeHandler,
        IERC20Ext _token,
        uint256 _amount
    ) public {
        kyberProxy = _kyberProxy;
        feeHandler = _feeHandler;
        token = _token;
        amount = _amount;
        require(_token.approve(address(_kyberProxy), _amount));
    }

    function setReentrancy(bool _isReentrancy) external {
        isReentrancy = _isReentrancy;
    }

    receive() external payable {
        if (!isReentrancy) {
            return;
        }

        bytes memory hint;
        kyberProxy.tradeWithHintAndFee(
            token,
            amount,
            ETH_TOKEN_ADDRESS,
            msg.sender,
            MAX_QTY,
            0,
            address(this),
            100,
            hint
        );
    }
}
