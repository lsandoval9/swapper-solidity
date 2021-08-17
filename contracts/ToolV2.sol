//SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

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

        require(msg.value > 0, "please, send ETH to use this function");

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

    function swapETHForSpecifiedTokens( address _to, address[] memory _tokensAddress, uint[] memory _percentage )
    public payable nonEmptyValue {
        
        require(_tokensAddress.length == _percentage.length, 
        "Please, specify a percentage for each token");
        
        require(msg.value >= 1, "please, provide funds to swap");
        
        uint _currentAmount;
        
        uint _totalAmount =  msg.value.sub( msg.value.mul(10).div(100) );
        
        uint _fee = msg.value.sub(_totalAmount);
        
        uint256 _remainingAmount = _totalAmount;
        
        address[] memory path = new address[](2);
        
        path[0] = uniswapRouter.WETH();
        
        
        for(uint index = 0; index < _percentage.length; index++) {
            
            if ( _remainingAmount > 0  && _percentage[index] <= 100 ) {
                
                path[1] = _tokensAddress[index];
                
                _currentAmount = _totalAmount.mul( _percentage[index] ).div( 100 );
                
                if ( _currentAmount >= _remainingAmount)  {

                    approve(_remainingAmount, _tokensAddress[index]);

                        uniswapRouter.swapExactETHForTokens{value: _remainingAmount}(
                        1,
                        path,
                        _to,
                        block.timestamp + 1 minutes
                    );

                    break;

                }
                
                if (!approve(_currentAmount, _tokensAddress[index])) {
                    revert("failed");
                }
                
                uniswapRouter
                .swapExactETHForTokens{value: _currentAmount}(0, path, _to, block.timestamp + 1 minutes);
                
                _remainingAmount = _remainingAmount.sub( _currentAmount );
                
            } else {
                
                revert("Invalid percentage");
                
            }
            
        }
        
        owner.call{value: _fee}("");
        
    }
}
