pragma solidity >=0.4.22 <0.6.0;

contract GameMarket {
	//卖家
    address public seller;
	
	//结束时间
    uint public endTime;
    
    //最高出价 
    address public highestBidder;
    uint public highestBid;

	//卖家和出价对应
    mapping(address => uint) pendingBidder;

	//是否结束
    bool ended;

	//出现更高出价引发的事件
    event HighestBidIncreased(address bidder, uint amount);
	
	//竞拍结束
    event AuctionEnded(address winner, uint amount);

	//构造函数
    constructor(
        uint _biddingTime,
        address _seller
    ) public {
        seller = _seller;
        endTime = now + _biddingTime;
    }
	
	//货物
	struct Good {
		address goodSeller;
		uint startPrice;
		
		//属性值，可以自定义
		uint defense;
		uint attack;
		string name;
	}
	
	Good good;
	
	//货物是否存在
	bool existGood;
	
	//上架
	function onShelf(uint _startPrice, uint _defense, uint _attack, string _name) public {
		require (msg.sender == seller) ;
		
		good = Good({
			name: _name,
			goodSeller: seller,
			startPrice: _startPrice,
			defense: _defense,
			attack: _attack
		});
		
		existGood = true;
		
		highestBid = _startPrice;
		highestBidder = seller;
	}

	//出价
    function bid() public payable {
        require(
            now <= endTime,
            "Auction already ended."
        );
        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        if (highestBid != 0) {
            pendingBidder[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }
	
	//获取货物信息
	function getGood () public returns (string) {
		require(now <= endTime, "Auction is ended.");
		
		return good.name ;
	}
	
	//当出现更高的出价时，撤回自己之前的出价
    function withdraw() public returns (bool) {
        uint amount = pendingBidder[msg.sender];
        if (amount > 0) {
            pendingBidder[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                pendingBidder[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

	//结束
    function auctionEnd() public {
        require(now >= endTime, "Auction not yet ended.");
        require(!ended, "auctionEnd has already been called.");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
		
		if(existGood == true) {
			good.goodSeller = highestBidder;
		}

        seller.transfer(highestBid);
    }
}