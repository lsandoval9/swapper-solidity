pragma solidity ^0.6.6;

import "./IERC20Upgradeable.sol";


interface IKyberNetworkProxy {
    
    function getExpectedRate(
        IERC20Upgradeable src,
        IERC20Upgradeable dest,
        uint256 srcQty
    ) external view returns (uint256 expectedRate, uint256 worstRate);
    
    function trade(
        IERC20Upgradeable src,
        uint256 srcAmount,
        IERC20Upgradeable dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet
    ) external payable returns (uint256);
    
}