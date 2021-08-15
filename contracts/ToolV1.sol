//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interfaces/UniswapV2Router02";
import "./interfaces/IERC20Upgradeable";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v3.2.0/contracts/proxy/Initializable.sol";

contract ToolV1 is Initializable {
    address payable public owner;

    IUniswapV2Router02 uniswapRouter;

    IERC20Upgradeable token; // = ERC20Upgradeable(0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa);

    using SafeMathUpgradeable for uint256;

    function initialize(address _uniswapV2Address) public initializer {
        uniswapRouter = IUniswapV2Router02(_uniswapV2Address);
        owner = msg.sender;
    }

    function approve(uint256 _amount, address _token) private returns (bool) {
        return
            IERC20Upgradeable(_token).approve(address(uniswapRouter), _amount);
    }

    function swapETHForTokens(
        uint256 _minAmount,
        address _to,
        address _token
    ) public payable {
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

    function swap(
        address _to,
        address[] memory _tokensAddress,
        uint256[] memory _percentage
    ) public payable {
        require(
            _tokensAddress.length == _percentage.length,
            "Please, specify a percentage for each token"
        );

        uint256 _amountWithoutFee;

        uint256 _totalAmount = msg.value.sub(msg.value.mul(10).div(100));

        uint256 _fee = msg.value.sub(_totalAmount);

        address[] memory path = new address[](2);

        path[0] = uniswapRouter.WETH();

        for (uint256 index = 0; index < _percentage.length; index++) {
            if (_totalAmount > 0 && _percentage[index] <= 100) {
                path[1] = _tokensAddress[index];

                _amountWithoutFee = _totalAmount.mul(_percentage[index]).div(
                    100
                );

                if (!approve(_amountWithoutFee, _tokensAddress[index])) {
                    revert("failed");
                }

                uniswapRouter.swapExactETHForTokens{value: _amountWithoutFee}(
                    1,
                    path,
                    _to,
                    block.timestamp + 1 minutes
                );

                _totalAmount.sub(_amountWithoutFee);
            } else {
                revert("Invalid percentage");
            }
        }

        owner.call{value: _fee}("");
    }
}
