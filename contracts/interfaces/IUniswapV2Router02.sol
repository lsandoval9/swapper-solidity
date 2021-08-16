pragma solidity ^0.6.6;

interface IUniswapV2Router02 {
    function swapExactETHForTokens(
        uint256 _amountOutMin,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) external payable returns (uint256[] memory amounts);

    function WETH() external pure returns (address);
}
