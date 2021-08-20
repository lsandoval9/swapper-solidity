# Swapper-eyss

---

An ethereum tool to make multiple swaps using uniswapV2 (ToolV1) and uniswapV2/kyberV2 (ToolV2)

---

## Usage

-   ### ToolV1

    Simple contract to make multiple swaps using UniswapV2. The toold consist in an upgradeable contract with a main function to swap ETH for tokens called "swapETHForSpecifiedTokens"

    #### swapETHForSpecifiedTokens

    #### params:

-   <b>address \_to </b>:<br>

    the recipient address to send the tokens

-   <b>address[] \_tokensAddress </b>:<br>

    An array containing the addresses of the tokens to swap. Ex. ["0xf0...", "0x6b..."]

-   <b>uint256[] \_percentages </b>:<br>

    An array containing the desired percentages to swap for each token in the same order declared in the array \_\_tokensAddress.

    Ex. [60, 40] - the 60% will be for the first token declared in the array "\_tokensAddress" and the 40% for the token of the second address.

-   <b> Requirements </b>: <br>

    -   <b>\_tokensAddress</b> and <b>\_percentages</b> must have the same length.

    -   you must send ether to use the function

    -   A fee of 0.1% will be charged to the user

-   ### ToolV2

    Upgraded version of ToolV1 which also use kyber to swap ETH for tokens. It consist mainly in two functions <b>swapETHForSpecifiedTokens</b> and <b>swapETHForTokensKyber</b>. Both functions receive the same params as the <b>swapETHForSpecifiedTokens</b>  function in ToolV1.

    ToolV2 also has a fuction called "migrate" to instantiate kyberNetworkProxy, which is used to swap ETH for tokens on the kyber network. 
      
      <b><i> Migrate must be called correctly before using any other function.</i></b>

    #### migrate

    ##### params: 

    * <b>address _kyberNetworkProxy</b>:

        The address of the KyberNetworkProxy contract.



----


## NPM scripts

    npm run fork

run a node that forks mainnet

    npm run deploy

deploy ToolV1 in a running node

    npm run upgrade

upgrade the base contract (ToolV1) to ToolV2

----
## Useful addresses

### Contracts

* <b>UniswapRouterV2 (mainnet) </b>- 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

* <b> KyberNetworkProxy (mainnet) </b>-                                 0x818E6FECD516Ecc3849DAf6845e3EC868087B755

### Tokens

* <b> DAI (mainnet)</b> - 0x6B175474E89094C44Da98b954EedeAC495271d0F

* <b> USDT (mainnet) </b> - 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48

* <b> LINK (mainnet) </b> - 0x514910771af9ca656af840dff83e8264ecf986ca

* <b> USDC (mainnet) </b> - 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48