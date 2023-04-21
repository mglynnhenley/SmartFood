// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Market.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Produce is Ownable{
    address public farmer;
    address public market;
    address[] private orders;
    uint256 public limitOnPendingOrders;

    bytes32 public produceHash;
    uint256 public price;
    uint256 public orderSize;

    enum State {
        UNINITIALIZED,
        OPEN,
        CLOSED
    }
    State private state;

    constructor() {
        state = State.UNINITIALIZED;
    }

    function initilize(
        address _farmer,
        bytes32 _produceHash,
        uint256 _price,
        uint256 _orderSize,
        uint256 _limitOnPendingOrders
    ) external {
        require(state==State.UNINITIALIZED, "This produce has already been initilized");
        _transferOwnership(_farmer);
        market = msg.sender;
        limitOnPendingOrders = _limitOnPendingOrders;
        produceHash = _produceHash;
        price = _price;
        orderSize = _orderSize;
        state = State.OPEN;
    }

    /// Place an order an order of the produce
    function placeOrder() external payable {
        require(
            msg.sender != owner(),
            "farmer cannot place order for their own produce"
        );
        require(
            msg.value == orderSize * price,
            "order must be of correct size and price"
        );
        require(orders.length < limitOnPendingOrders, "too many orders pending for this produce");
        orders.push(msg.sender);
    }

    /// This allows farmers to take a single produceOrder
    function takeOrder() external onlyOwner returns (address order) {
        require(orders.length > 0, "No orders to take");
        address orderToTake = orders[orders.length - 1];
        orders.pop();
        return orderToTake;
    } 

}
