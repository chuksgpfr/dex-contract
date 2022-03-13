// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DEX  {

  constructor() {
    admin = msg.sender;
  }

  using SafeMath for uint;

  enum Sides {
    BUY,
    SELL
  }

  struct Token {
    bytes32 ticker;
    address tokenAddress;
  }

  struct Order {
    uint id;
    address trader;
    bytes32 ticker;
    Sides side;
    uint amount;
    uint filled; // defaults to zero when created
    uint price;
    uint date;
  }

  mapping(bytes32 => Token) public tokens;
  bytes32[] public tokenList;
  address public admin;
  mapping(address => mapping(bytes32 => uint)) public traderBalances;
  mapping(bytes32 => mapping(uint => Order[])) orderBook;
  bytes32 constant DAI = bytes32("DAI");
  uint public nextOrderId;
  uint public nextTradeId;
  /// trader1 is trader that made the request
  event NewTrade(
    uint tradeId,
    uint orderId,
    bytes32 indexed ticker,
    address indexed trader1,
    address indexed trader2,
    uint amount,
    uint price,
    uint date
  );

  function addToken(bytes32 _ticker, address _tokenAddress) onlyAdmin() external {
    tokens[_ticker] = Token(_ticker, _tokenAddress);
    tokenList.push(_ticker);
  }

  function deposit(uint _amount, bytes32 _ticker) tokenExist(_ticker) external {
    IERC20(tokens[_ticker].tokenAddress).transferFrom(msg.sender, address(this), _amount);
    traderBalances[msg.sender][_ticker] = traderBalances[msg.sender][_ticker].add(_amount);
  }

  function withdraw(uint _amount, bytes32 _ticker) tokenExist(_ticker) external {
    require(traderBalances[msg.sender][_ticker] >= _amount, "Insufficient balance");
    IERC20(tokens[_ticker].tokenAddress).transfer(msg.sender, _amount);
    traderBalances[msg.sender][_ticker] = traderBalances[msg.sender][_ticker].sub(_amount);
  }

  function createLimitOrder(bytes32 ticker, uint amount, uint price, Sides side) tokenExist(ticker) tokenNotDai(ticker) external {
    if (side == Sides.SELL) {
      require(traderBalances[msg.sender][ticker] >= amount, "You have low funds");
    } else {
      require(traderBalances[msg.sender][DAI] >= amount * price, "You have low funds");
    }

    // creating order
    Order[] storage orders = orderBook[ticker][uint(side)];
    orders.push(Order(
      nextOrderId,
      msg.sender,
      ticker,
      side,
      amount,
      0,
      price,
      block.timestamp
    ));

    uint i = orders.length > 0 ? orders.length - 1 : 0;

    while(i > 0) {
      if (side == Sides.BUY && orders[i-1].price > orders[i].price) {
        break;
      }
      if (side == Sides.SELL && orders[i-1].price < orders[i].price) {
        break;
      }
      // copy previous order and replace
      Order memory prevOrder = orders[i-1];
      orders[i-1] = orders[i];
      orders[i] = prevOrder;
      i--;
    }
    nextOrderId++;
  }

  function createMarketOrder(bytes32 ticker, uint amount, Sides side) tokenExist(ticker) external {
    if (side == Sides.SELL) {
      require(traderBalances[msg.sender][ticker] >= amount, "Insufficient balance");
    }
    Order[] storage orders = orderBook[ticker][uint(side == Sides.BUY ? Sides.SELL : Sides.BUY)];
    uint i; 
    uint remianing = amount;

    while (i < orders.length && remianing > 0) {
      uint availableLP = orders[i].amount.sub(orders[i].filled);
      uint matched = (remianing > availableLP) ? availableLP : remianing;
      orders[i].filled += matched;

      emit NewTrade( 
        nextTradeId,
        orders[i].id,
        ticker,
        msg.sender,
        orders[i].trader,
        amount,
        orders[i].price,
        block.timestamp
      );

      if (side == Sides.SELL) {
        traderBalances[msg.sender][ticker].sub(matched);
        traderBalances[msg.sender][DAI].add(matched.mul(orders[i].price));

        traderBalances[orders[i].trader][ticker].add(matched);
        traderBalances[orders[i].trader][DAI].sub(matched.mul(orders[i].price));
      }

      if (side == Sides.BUY) { 
        require(traderBalances[msg.sender][DAI] >= matched.mul(orders[i].price), "DAI too low");
         
        traderBalances[msg.sender][ticker].add(matched);
        traderBalances[msg.sender][DAI] -= matched * orders[i].price; 

        traderBalances[orders[i].trader][ticker] -= matched;
        traderBalances[orders[i].trader][DAI].add(matched.mul(orders[i].price));
      }

      remianing.sub(matched); 
      i++;
      nextTradeId++;
    }

    i = 0;
    while(i < orders.length && orders[i].filled == orders[i].amount) {
      for (uint256 j = i; j < orders.length; j++) {
        orders[j] = orders[j+1];
      }
      orders.pop();
      i++;
    }
  }

  function getOrders(bytes32 ticker, Sides side) external view returns(Order[] memory) {
    return orderBook[ticker][uint(side)];
  }

  function getTokens() external view returns(Token[] memory) {
    Token[] memory _tokens = new Token[](tokenList.length);
    for (uint i = 0; i < tokenList.length; i++) {
      _tokens[i] = Token(
        tokens[tokenList[i]].ticker,
        tokens[tokenList[i]].tokenAddress
      );
    }
    return _tokens;
  }

  modifier tokenNotDai(bytes32 ticker) {
    require(ticker != DAI, "You cannot trade DAI");
    _;
  }
  modifier tokenExist(bytes32 _ticker) {
    require(tokens[_ticker].tokenAddress != address(0), "Token does not exist");
    _;
  }
  modifier onlyAdmin() {
    require(msg.sender == admin, "Only admin is required");
    _;
  }
}