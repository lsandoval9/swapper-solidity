//SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IERC20Upgradeable.sol";
import "./interfaces/IKyberNetworkProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

contract ToolV2 is Initializable {

    address payable public owner;

    IUniswapV2Router02 uniswapRouter;

    IERC20Upgradeable token;

    IKyberNetworkProxy kyberNetworkProxy;

    using SafeMathUpgradeable for uint256;

    modifier nonEmptyValue() {
        require(msg.value > 0, "please, send ETH to use this function");

        _;
    }

    function initialize(address _uniswapV2Address)
        public
        initializer
    {
        uniswapRouter = IUniswapV2Router02(_uniswapV2Address);
        owner = msg.sender;
    }

    function migrate( address _kyberNetworkProxy) public {
        require(msg.sender == owner);

        kyberNetworkProxy = IKyberNetworkProxy(_kyberNetworkProxy);
    }

    function approve(uint256 _amount, address _token) private returns (bool) {
        return
            IERC20Upgradeable(_token).approve(address(uniswapRouter), _amount);
    }

    function swapETHForTokens(
        uint256 _minAmount,
        address _to,
        address _token
    ) public payable nonEmptyValue {
        address[] memory path = new address[](2);

        path[0] = uniswapRouter.WETH();

        path[1] = _token;

        uniswapRouter.swapExactETHForTokens{value: msg.value}(
            _minAmount,
            path,
            _to,
            block.timestamp + 1 minutes
        );
    }

    function swapETHForSpecifiedTokens(
        address _to,
        address[] memory _tokensAddress,
        uint256[] memory _percentage
    ) public payable nonEmptyValue {
        require(
            _tokensAddress.length == _percentage.length,
            "Please, specify a percentage for each token"
        );

        require(msg.value >= 1, "please, provide funds to swap");

        uint256 _currentAmount;

        uint256 _totalAmount = msg.value.sub(msg.value.mul(1).div(1000));

        uint256 _fee = msg.value.sub(_totalAmount);

        uint256 _remainingAmount = _totalAmount;

        address[] memory path = new address[](2);

        path[0] = uniswapRouter.WETH();

        for (uint256 index = 0; index < _percentage.length; index++) {
            if (_remainingAmount > 0 && _percentage[index] <= 100) {
                path[1] = _tokensAddress[index];

                _currentAmount = _totalAmount.mul(_percentage[index]).div(100);

                if (_currentAmount >= _remainingAmount) {
                    uniswapRouter.swapExactETHForTokens{
                        value: _remainingAmount
                    }(1, path, _to, block.timestamp + 1 minutes);

                    break;
                }

                if (!approve(_currentAmount, _tokensAddress[index])) {
                    revert("failed");
                }

                uniswapRouter.swapExactETHForTokens{value: _currentAmount}(
                    0,
                    path,
                    _to,
                    block.timestamp + 1 minutes
                );

                _remainingAmount = _remainingAmount.sub(_currentAmount);
            } else {
                revert("Invalid percentage");
            }
        }

        if (_remainingAmount > 0) {
            uniswapRouter.swapExactETHForTokens{value: _remainingAmount}(
                1,
                path,
                _to,
                block.timestamp + 1 minutes
            );
        }

        owner.call{value: _fee}("");
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
                        ), // WBTC token address
                        _currentToken, // KNC token address
                        _remainingAmount // 1 WBTC
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
                    ), // WBTC token address
                    _currentToken, // KNC token address
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

        if (_remainingAmount > 0) {
            (expectedRate, ) = kyberNetworkProxy.getExpectedRate(
                IERC20Upgradeable(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), // WBTC token address
                _currentToken, // KNC token address
                _remainingAmount // 1 WBTC
            );

            kyberNetworkProxy.trade{value: _remainingAmount}(
                IERC20Upgradeable(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),
                _remainingAmount,
                _currentToken,
                _to,
                9999999999999999999999999999999,
                expectedRate,
                owner
            );
        }

        owner.call{value: _fee}("");
    }
}
