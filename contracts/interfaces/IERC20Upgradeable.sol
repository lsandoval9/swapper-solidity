pragma solidity ^0.6.6;


interface IERC20Upgradeable {
    
    function approve(address spender, uint256 amount) 
    external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    
}