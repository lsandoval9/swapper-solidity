//SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IERC20Upgradeable.sol";
import "./interfaces/IKyberNetworkProxy.sol";
import "./ToolV1.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

contract ToolV2 is ToolV1 {

    IKyberNetworkProxy kyberNetworkProxy;

    using SafeMathUpgradeable for uint256;

    function initialize()
        public
        initializer
    {
        ToolV1.initialize(address(ToolV1.uniswapRouter));
    }

    function migrate( address _kyberNetworkProxy) public {
        require(msg.sender == owner);

        kyberNetworkProxy = IKyberNetworkProxy(_kyberNetworkProxy);
    }


    function swapETHForTokensKyber(
        address payable _to,
        address[] memory _tokensAddress,
        uint256[] memory _percentages
    ) public payable nonEmptyValue {
        
        uint256 _currentAmount;

        uint256 _totalAmount = msg.value.sub(msg.value.mul(10).div(1000));

        uint256 _fee = msg.value.sub(_totalAmount);

        uint256 _remainingAmount = _totalAmount;

        uint256 expectedRate;

        IERC20Upgradeable _currentToken;

        for (uint256 index = 0; index < _percentages.length; index++) {
            if (_percentages[index] <= 100) {
                _currentToken = IERC20Upgradeable(_tokensAddress[index]);

                _currentAmount = _totalAmount.mul(_percentages[index]).div(100);

                if (_currentAmount >= _remainingAmount) {
                    (expectedRate, ) = kyberNetworkProxy.getExpectedRate(
                        IERC20Upgradeable(
                            0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
                        ), 
                        _currentToken,
                        _remainingAmount 
                    );

                    kyberNetworkProxy.trade{value: _remainingAmount}(
                        IERC20Upgradeable(
                            0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
                        ),
                        _remainingAmount,
                        _currentToken,
                        _to,
                        9999999999999999999999999999999,
                        expectedRate,
                        owner
                    );

                    break;
                }

                (expectedRate, ) = kyberNetworkProxy.getExpectedRate(
                    IERC20Upgradeable(
                        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
                    ),
                    _currentToken,
                    _currentAmount
                );

                kyberNetworkProxy.trade{value: _currentAmount}(
                    IERC20Upgradeable(
                        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
                    ),
                    _currentAmount,
                    _currentToken,
                    _to,
                    9999999999999999999999999999999,
                    expectedRate,
                    owner
                );

                _remainingAmount = _remainingAmount.sub(_currentAmount);
            } else {
                revert("Invalid percentage");
            }
        }

        owner.call{value: _fee}("");
    }
}
