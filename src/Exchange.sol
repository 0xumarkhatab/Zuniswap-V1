// contracts/Exchange.sol
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {
    address public tokenAddress;

    constructor(address _token) {
        require(_token != address(0), "invalid token address");
        tokenAddress = _token;
    }

    function addLiquidity(uint256 _tokenAmount) public payable {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
    }

    function getReserve() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    /*

Constant Product Formula
(x+Δx)(y−Δy)=xy

Δy= yΔx / x+Δx
​
Input  : X
Output : Y
*/
    function getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) private pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        // Δy= yΔx / x+Δx
        return (inputAmount * outputReserve) / (inputReserve + inputAmount);
    }

    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "ethSold is too small");

        uint256 tokenReserve = getReserve();

        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "tokenSold is too small");

        uint256 tokenReserve = getReserve();

        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    function ethToTokenSwap(uint256 _minTokens) public payable {
        uint256 tokenReserve = getReserve();
        uint256 tokensBought = getAmount(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );

        require(tokensBought >= _minTokens, "insufficient output amount");

        IERC20(tokenAddress).transfer(msg.sender, tokensBought);
    }
    function tokenToETHSwap(uint token_amount,uint256 _minETH) public payable {
        uint256 ethReserve = address(this).balance;
        uint token_balance_before=getReserve();

        uint256 ethBought = getAmount(
            token_amount,
            token_balance_before,
            ethReserve
        );
        require(ethBought >= _minETH, "insufficient output amount");
        payable(msg.sender).call{value:ethBought}(" ");
    }

    //  Deprecated - Constant Sum formula
    // function getPrice(
    //     uint256 inputReserve,
    //     uint256 outputReserve
    // ) public pure returns (uint256) {
    //     require(inputReserve > 0 && outputReserve > 0, "invalid reserves");

    //     return (inputReserve * 1e18) / outputReserve;
    // }
}
