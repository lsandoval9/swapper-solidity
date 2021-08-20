//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

contract ToolV1 is Initializable {
    
    address payable public owner;

    IUniswapV2Router02 uniswapRouter;

    IERC20Upgradeable token;

    using SafeMathUpgradeable for uint256;

    modifier nonEmptyValue() {
        require(msg.value > 0, "Insufficient amount");

        _;
    }

    function initialize(address _uniswapV2Address) public initializer {
        uniswapRouter = IUniswapV2Router02(_uniswapV2Address);
        owner = msg.sender;
    }

    function approve(uint256 _amount, address _token) private returns (bool) {
        return
            IERC20Upgradeable(_token).approve(address(uniswapRouter), _amount);
    }

    function swapETHForTokens(
        address payable _to,
        address[] memory _tokensAddress,
        uint256[] memory _percentages
    ) public payable nonEmptyValue {
        require(
            _tokensAddress.length == _percentages.length,
            "Please, specify a percentage for each token"
        );

        uint256 _currentAmount;

        uint256 _totalAmount = msg.value.sub(msg.value.div(1000));

        uint256 _fee = msg.value.sub(_totalAmount);

        uint256 _remainingAmount = _totalAmount;

        address[] memory path = new address[](2);

        path[0] = uniswapRouter.WETH();

        for (uint256 index = 0; index < _percentages.length; index++) {

            if (_remainingAmount > 0 && _percentages[index] <= 100) {

                path[1] = _tokensAddress[index];

                _currentAmount = _totalAmount.mul(_percentages[index]).div(100);

                if (_currentAmount >= _remainingAmount) {
                    uniswapRouter.swapExactETHForTokens{
                        value: _remainingAmount
                    }(0, path, _to, block.timestamp + 1 minutes);

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


        owner.call{value: _fee}("");
    }
}
