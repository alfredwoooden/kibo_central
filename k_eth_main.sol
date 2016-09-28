// main proxy contract
contract K_Eth_v5 {
	// constants
	struct K_Eth_Constants {
		uint price_4_big; 		// price for 1 kibit
		uint kibits_4_ether;	// kibits amount for 1 ether
		uint price_4_small;		// price for partnership
		uint money_have;		// money collected on crowdsale
		uint sale_period;		// period when kibits and partner tokens are avaliable for buyin
		uint sale_left;			// time for crowdsale end
		uint sale_start;		// timestamp of crowdsale start
		uint sale_end;			// timestamp of crowdsale end
		address root_wallet;	// contract creater
		address admin_wallet;	// wallet with privileges to import users
		address s_wallet;		// safe
    }
	
	// contracts list
	struct K_Eth_Contracts {
		K_Users2 users;
		K_Ballot ballot;
		address ballot_address;
		address users_address;
	}
	
	// free tickets and dividends for partners and players
	struct Temp_User {
		address wallet;
		uint psum;		// from that sum dividends were already payed;
		uint[12] free_1;	// free tickets for 6/49
		uint[12] free_2;	// free tickets for joker
		uint game_1;	// drawing to start count free tickets spending
		uint game_2;	// drawing to start count free tickets spending
	}
	
	struct K_Eth_Game {
		address game_address; 	// game contracts address
		uint active;			// flag to turn game on(1)/off(0)
		uint price;				// ticket price
		uint drawing;
		mapping (uint => uint) group_game_price; // groupgame part price
	}
	
	mapping(uint => K_Eth_Game) games; 	// game contracts list
	uint games_length;					// length of game contracts list mapping
	
	// structure for through users iterations
	mapping(address => uint) temp_user2index;   
	mapping(uint => Temp_User) index2temp_user;
	uint temp_user_length = 0;
	
	uint public profit;				// contract profit on selling tickets
	uint pay_dividends_length;		// paying dividends iterator
	uint pay_dividends_timestamp;	// timestamp (to spread iterations for several blocks)
	
	uint[7] ref4level; // partners you need to get referral bonuses
	K_Eth_Constants public constants;
	K_Eth_Contracts public contracts;
	
	uint public day = 1; // day of crowdsale
	
	modifier onlyVotes { if (msg.sender != contracts.ballot_address) throw; _ } // only voting contract
	modifier onlyOwner { if (msg.sender != constants.root_wallet) throw; _ }	// only contract creator
	modifier onlyAdmin { if (msg.sender != constants.admin_wallet) throw; _ }	// only privileges holder
	modifier onlyLotto { if (msg.sender != games[1].game_address && msg.sender != games[2].game_address) throw; _ } // only game
	modifier SaleIsOn { if (block.timestamp < constants.sale_start || constants.sale_end != 0) throw; _ }  // only during crowdsale
	modifier SaleIsNotEnded { if (constants.sale_end != 0) throw; _ }  // only during crowdsale
	
	function K_Eth_v5 (address _admin, address _s) {
		constants.price_4_big = 20000000000000000; // 50 for 1 ether
		constants.kibits_4_ether = 50;
		constants.price_4_small = 10 ether; // 1 ether
		
		constants.money_have = 0;
		
		constants.sale_start = block.timestamp + 369600;	
		constants.sale_end = 0;	
		constants.sale_period = 40 days;		
		constants.sale_left = 40 days;
		
		constants.root_wallet = msg.sender;
		constants.admin_wallet = _admin;
		constants.s_wallet = _s;
		
		profit = 0;
		pay_dividends_length = 0;
		pay_dividends_timestamp = block.timestamp;
		index2temp_user[temp_user_length].wallet = msg.sender;
		index2temp_user[temp_user_length].psum = 0;
		temp_user2index[msg.sender] = temp_user_length;
		temp_user_length += 1;
		
		ref4level = [2,3,3,4,5,6,7]; // partners you need to get referral bonuses
    }
	
	// changes kibits price, and crowdsale timestamps during crowdsale
	function setSalePeriod() private {
		if (constants.sale_end == 0 && block.timestamp > constants.sale_start) {
			if (block.timestamp > constants.sale_start + constants.sale_period) {
				endSalePeriod();
			} else {
				constants.sale_left = constants.sale_period - (block.timestamp - constants.sale_start); 
				uint cur_day;
				cur_day = (constants.sale_period - constants.sale_left) / 1 days + 1;
				if (day < cur_day) {
					day = cur_day;
					// price for kibit changes during the crowdsale
					if (day >= 30 && constants.price_4_big < 1 ether / 25) {
						constants.price_4_big = 1 ether / 25;
						constants.kibits_4_ether = 25;
					}	
					if (day >= 20 && constants.price_4_big < 1 ether / 30) {
						constants.price_4_big = 1 ether / 30;
						constants.kibits_4_ether = 30;
					}	
					if (day >= 10 && constants.price_4_big < 1 ether / 35) {
						constants.price_4_big = 1 ether / 35;
						constants.kibits_4_ether = 35;
					}	
					if (day >= 5 && constants.price_4_big < 1 ether / 40) {
						constants.price_4_big = 1 ether / 40;
						constants.kibits_4_ether = 40;
					}	
				}
			}
		}
	}
	
	// when crowdsale ends
	function endSalePeriod() private {
		constants.sale_end = block.timestamp;
	}
	
	// register partner/player 
	// _type: 0 - partner, 1 - player
	// _token: 1 - partner token, 2 - kibits
	function register(uint _type, string _username, string _parentname, uint _token) {
		// checking username existance
		if (contracts.users.checkUsername(_username) == false) {
			uint drawing_1 = games[1].drawing > 0 ? games[1].drawing : 1;
			uint drawing_2 = games[2].drawing > 0 ? games[2].drawing : 1;
			index2temp_user[temp_user_length].wallet = msg.sender;
			index2temp_user[temp_user_length].psum = profit;
			index2temp_user[temp_user_length].free_1 = [3,3,3,3,3,3,3,3,3,3,3,3];
			index2temp_user[temp_user_length].free_2 = [3,3,3,3,3,3,3,3,3,3,3,3];
			index2temp_user[temp_user_length].game_1 = games[1].drawing;
			index2temp_user[temp_user_length].game_2 = games[2].drawing;
			temp_user2index[msg.sender] = temp_user_length;
			temp_user_length += 1;
			if (_type == 0) {
				contracts.users.registerPartner(msg.sender, _username, _parentname, 0);
				contracts.users.registerPlayer(msg.sender, _username, _parentname);
				if (_token == 1) {
					setSmall();
				} else if (_token == 2) {
					setBig();
				}
			} else if (_type == 1) {
				contracts.users.registerPlayer(msg.sender, _username, _parentname);
			}
		}	
    }
	
	// referral payouts
	function payPartnerRefs (uint _package, uint _value, uint _change) private {
		uint refs = 0;
		// get first parent to pay referrals
		address recipient = contracts.users.getPartnerParents(msg.sender)[0];
		// new partner or partner registered before crowdsale
		// different payouts for different types
		uint p_type = contracts.users.getPartnerType(recipient);
		if (contracts.users.getSmall(recipient) > 0) {
			// if partner was registered before crowdsale he gets referral bonuses from both kibits and partner tokens
			if (p_type > 0) {
				if (_package == 1) {
					refs = 3 ether;
				} else if (_package == 2) {
					refs += (_value * constants.price_4_big) / 100 * 15;
				} else if (_package == 3) {
					refs = 3 ether;
					refs += (_value * constants.price_4_big) / 100 * 15;
				}
			// else he gets referral bonuses only from partner tokens	
			} else {
				if (_package == 1 || _package == 3) {
					refs = 3 ether;	
				}	
			}
			if (!recipient.send(refs)) throw;
		}
		constants.s_wallet.send((msg.value - _change) - refs);
		constants.money_have += (msg.value - _change) - refs;
		setSalePeriod();
	}	
	
	// calculate amount of kibits from msg.value
	function calculateBig(uint _value) constant returns (uint[2] ret_big) {
		uint change = _value % 1 ether;
		uint amount = ((_value - change) / 1 ether) * constants.kibits_4_ether;
		if (amount < 1) throw;
		return [amount, change];
    }
	
	function setBig() SaleIsOn {
		uint[2] memory values;
		uint package = 2;
		// checking partner existance
		if (contracts.users.checkPartner(msg.sender)) {
			if (contracts.users.getSmall(msg.sender) == 0) {
				// first buy includes partner token and 5000 kibits - 110 ether 
				if (msg.value < 100 ether + getPrice4Small()) throw;
				values = calculateBig(msg.value - getPrice4Small());
				contracts.users.setSmall(msg.sender, 1);
				package = 3;
			} else {
				// first kibits buy should be 100 ether
				if (contracts.users.getBig(msg.sender) == 0 && msg.value < 100 ether) throw;
				values = calculateBig(msg.value);
			}
			uint value = values[0];
			uint change = values[1];
			uint tokens_left = contracts.users.getBigLimit();
			// if amount of kibits in contract is enough
			if (tokens_left <  value || tokens_left - value > tokens_left) throw; 
			if (contracts.users.getBig(msg.sender) + value < contracts.users.getBig(msg.sender)) throw; 
			contracts.users.setBig(msg.sender, value);
			if (change > 0) {
				msg.sender.send(change);
			}
			// payout referrals
			payPartnerRefs(package, value, change);
		} else {
			throw;
		}
		setSalePeriod();
	}
	
	function calculateSmall(uint _value) constant returns (uint ret_change) {
		if (_value < constants.price_4_small) throw;
		return _value - 1 * constants.price_4_small;
	}
	
	function setSmall() SaleIsNotEnded {
		// checking partner existance
		if (contracts.users.checkPartner(msg.sender)) {
			if (contracts.users.getSmallLimit() <= 5000) throw;
			uint change = calculateSmall(msg.value);
			if (contracts.users.getSmallLimit() < 1) throw;
			if (contracts.users.getSmall(msg.sender) > 0 || contracts.users.getBig(msg.sender) > 0) throw;
			contracts.users.setSmall(msg.sender, 1);
			if (change > 0) {	
				msg.sender.send(change);
			}	
			// payout referrals
			payPartnerRefs(1, 1, change);
		} else {
			throw;
		}
		setSalePeriod();
	}
	
	function calculateTicket (uint _value, uint _drawing, uint _id) internal constant returns (uint[2] ret_ticket) {
		uint amount = 1; 
		if (amount < 1) throw;
		if (games[_id].price * _drawing > _value) throw;
		uint change = _value - amount * games[_id].price * _drawing;
		return [amount, change];
	}
	
	// amount of available free tickets
	// _id - id of game (6/49 or joker) 
	function getFreeTickets(uint _id) constant returns (uint ret_value) {
		// drawings passed since partner registration
		uint passed = 0;	
		if (_id == 1) {
			if (index2temp_user[temp_user2index[msg.sender]].game_1 == 0) return 0;
			// calculating amount from drawing data
			return index2temp_user[temp_user2index[msg.sender]].free_1[games[1].drawing - index2temp_user[temp_user2index[msg.sender]].game_1];
		} else if (_id == 2) {
			if (index2temp_user[temp_user2index[msg.sender]].game_2 == 0) return 0;
			// calculating amount from drawing data
			return index2temp_user[temp_user2index[msg.sender]].free_2[games[2].drawing - index2temp_user[temp_user2index[msg.sender]].game_2];
		}
	}
	
	// "buying" free tickets
	function buyFreeTicket(uint _id, uint[6] _user_numbers, string _user_random) {
		if (_id == 1) {
			index2temp_user[temp_user2index[msg.sender]].free_1[games[1].drawing - index2temp_user[temp_user2index[msg.sender]].game_1] -= 1;
			// calling contract method.
			// Using "call" method cuz we need the opportunity 
			// to include new games without main proxy contract recreation.
			games[1].game_address.call(bytes4(sha3("buyFreeTicket(address,uint256[6],string)")), msg.sender, _user_numbers, _user_random);
		}
		if (_id == 2) {
			index2temp_user[temp_user2index[msg.sender]].free_2[games[2].drawing - index2temp_user[temp_user2index[msg.sender]].game_2] -= 1;
			games[2].game_address.call(bytes4(sha3("buyFreeTicket(address,uint256[6],string)")), msg.sender, _user_numbers, _user_random);
		}
	}
	
	// buying ticket
	// _user_random - random string for win numbers generation
	// _user_numbers - 6 numbers user choosed
	// _drawing - amount of games, user wants to play
	// _id - game id
	// _double - doubling bet for joker
	
	function buyTicket(string _user_random, uint[6] _user_numbers, uint _drawing, uint _id, uint _double) {
		// if game is available
		if (games[_id].active == 0) throw;
		// if sender is partner or player
		if (contracts.users.checkPlayer(msg.sender) || contracts.users.checkPartner(msg.sender)) {
			uint sum = 0;
			// if you have free available tickets, you can not buy tickets
			if (getFreeTickets(_id) > 0) {
				buyFreeTicket(_id, _user_numbers, _user_random);
				return;
			}
			uint[2] memory calculated = calculateTicket(msg.value, _drawing, _id);
			profit += msg.value - calculated[1];
			sum = (msg.value - calculated[1]) - pay4Ticket(calculated[1]) - payDividends();
			if (_id == 1) {
				games[1].game_address.call(bytes4(sha3("buyTicket(address,uint256[6],uint256,string)")), msg.sender, _user_numbers, _drawing, _user_random);
				games[1].game_address.call(bytes4(sha3("transferSum(uint256)")), sum);
				games[1].game_address.call.gas(200000).value(sum)();
			}
			if (_id == 2) {
				games[2].game_address.call(bytes4(sha3("buyTicket(address,uint256,uint256,uint256,string)")), msg.sender, _user_numbers, _drawing, _double, _user_random);
				games[2].game_address.call(bytes4(sha3("transferSum(uint256)")), sum);
				games[2].game_address.call.gas(200000).value(sum)();
				
			}
			// transfer sum payed for ticket to game contract;
			msg.sender.send(calculated[1]);
		} else {
			throw;
		}
	}
	
	function calculateGroupTicket(uint _value, uint _id, uint _amount, uint _length) internal constant returns (uint[2] ret_ticket) {
		if (_amount < 1) throw;
		if (games[_id].group_game_price[_length] * _amount > _value) throw;
		uint change = _value - _amount * games[_id].group_game_price[_length] * _amount;
		return [_amount, change];
	}

	// buying group ticket, mostly same to usual ticket
	function buyGroupTicket(uint _id, uint _length, uint _amount) {
		if (games[_id].active == 0) throw;
		if (contracts.users.checkPlayer(msg.sender) || contracts.users.checkPartner(msg.sender)) {
			uint sum = 0;
			uint[2] memory calculated = calculateGroupTicket(msg.value, _id, _amount, _length);
			profit += msg.value - calculated[1];
			sum = (msg.value - calculated[1]) - pay4Ticket(calculated[1]) - payDividends();
			games[_id].game_address.send(sum);
			games[_id].game_address.call(bytes4(sha3("buyGroupTicket(address,uint256,uint256)")), msg.sender, _length, _amount);
			games[_id].game_address.call(bytes4(sha3("transferSum(uint256)")), sum);
			msg.sender.send(calculated[1]);
		} else {
			throw;
		}
	}
	
	function pay4Ticket(uint _change) private returns (uint _ret_refs) {
		address parent; 	
		address[8] memory parents;
		uint parents_level_need;
		uint partner_type;
		uint level;
		uint refs;	
		// get senders parent-parent
		if (!contracts.users.checkPartner(msg.sender)) {
			for (uint i = 0; i < 7; i++) {
				// get first partner from player parents structure and its level
				if (contracts.users.checkPartner(contracts.users.getPlayerParents(msg.sender)[i])) {
					parent = contracts.users.getPlayerParents(msg.sender)[i];
					partner_type = contracts.users.getPartnerType(parent);
					level = i + 1;
					break;
				}
			}
		// if player is partner, he is his own parent 	
		} else {
			parent = msg.sender;
			partner_type = contracts.users.getPartnerType(parent);
			level = 1;
		}
		// create referral recipients chain
		parents[0] = parent;
		// 5 level structure for new partners
		if (partner_type == 1) {parents_level_need = 5;}
		// 7 level structure for partners registered before crowdsale
		else {parents_level_need = 7;}
		// do payouts if partners amount enough		
		if (level <= parents_level_need) {
			for (i = 1; i < 7; i++) {
				parents[i] = contracts.users.getPartnerParents(parents[0])[i];
			}
								
			for (i = 0; i < 7; i++) {
				if (contracts.users.getPartnersPerLevel(i + 1, parents[i]) >= ref4level[i]) {
					if (i == 0) {
						refs += (msg.value - _change) / 10;
						if (!parents[i].send((msg.value -_change) / 10)) throw;
					} else {
						refs += (msg.value - _change) / 100;
						if (!parents[i].send((msg.value - _change) / 100)) throw;
					}
				}	
			}	
		}
		return refs;
	}
	
	// payout dividends for every partner during several blocks
	function payDividends () private returns (uint ret_value) {
		uint total = 0;
		uint part = 0;
		// all dividends should be payed during through day
		if (block.timestamp - 1 days > pay_dividends_timestamp) {
			pay_dividends_timestamp = block.timestamp;
			pay_dividends_length = 0;
		}
		// 5 partners for iteration
		uint max = 5;
		if (temp_user_length - pay_dividends_length < 5) max = temp_user_length - pay_dividends_length;
		uint start = pay_dividends_length;
		uint end = pay_dividends_length + max;
		if (max > 0) {
			for (uint i = start; i < end; i++) {
				// partner gets his part for every partners kibit
				part = (((profit - index2temp_user[i].psum) / 100 * 14) / 350000000) * contracts.users.getBig(index2temp_user[i].wallet); 
				// minimum amout to pay. 
				// to avoid chance, when transaction fee will be bigger then payout
				if (part >= 36101083032490980) {
					if (!index2temp_user[i].wallet.send(part)) throw;
					index2temp_user[i].psum += profit;
					total += part;
				}
			}
			pay_dividends_length += max;
		}
		return total;
	}
	
	// import user by admin
	function importUser(address _address, string _username, string _parentname, uint _big, uint _small) onlyAdmin {
		index2temp_user[temp_user_length].wallet = _address;
		index2temp_user[temp_user_length].psum = profit;
		temp_user2index[_address] = temp_user_length;
		temp_user_length += 1;
		
		index2temp_user[temp_user_length - 1].free_1 = [3,3,3,3,3,3,3,3,3,3,3,3];
		index2temp_user[temp_user_length - 1].free_2 = [3,3,3,3,3,3,3,3,3,3,3,3];
		index2temp_user[temp_user_length - 1].game_1 = games[1].drawing;
		index2temp_user[temp_user_length - 1].game_2 = games[2].drawing;
				
		contracts.users.registerPartner (_address, _username, _parentname, 1);
		contracts.users.registerPlayer (_address, _username, _parentname);
		contracts.users.setBig(_address, _big);
		contracts.users.setSmall(_address, _small);
	}
	
	// call changing wallet function
	function changeWallet(address _donor, address _recipient) onlyAdmin {
		index2temp_user[temp_user_length] = index2temp_user[temp_user2index[_donor]];
		index2temp_user[temp_user_length].wallet = _recipient;
		temp_user2index[_donor] = temp_user_length;
		temp_user_length += 1;
		contracts.users.changeWallet(_donor, _recipient);
	}
	
	function getPrice4Big() constant returns (uint ret_val) {
		return constants.price_4_big;
	}
	
	function getPrice4Small() constant returns (uint ret_val) {
		return constants.price_4_small;
	}
	
	// set contract addresses
	// for opportunity to create contracts separately
	function setBallotAddress(address _address) onlyOwner {
		contracts.ballot = K_Ballot(_address);
		contracts.ballot_address = _address;
	}
	
	function setUsersAddress(address _address) onlyOwner {
		contracts.users = K_Users2(_address);
		contracts.users_address = _address;	
	}
	
	function setGameAddress(uint _id, address _address, uint _price) onlyOwner {
		games[_id].game_address = _address;
		games[_id].active = 1;
		games[_id].price = _price;
		games[_id].drawing = 1;
		games_length += 1;
	}
	
	// setters
	
	function setGameDrawing(uint _id, uint _drawing) onlyLotto {
		games[_id].drawing = _drawing;
	}
	
	function setGroupGamePrice(uint _id, uint _length, uint _price) {
		games[_id].group_game_price[_length] = _price;
	}
	
	function setGamePeriod(uint _id, uint _period) onlyVotes {
		games[_id].game_address.call(bytes4(sha3("setPeriod(uint256)")), _period);
	}
	
	function setGameTime(uint _id, uint _time) onlyVotes {
		games[_id].game_address.call(bytes4(sha3("setTime(uint256)")), _time);
	}
	
	function setPrice4Big(uint _value) onlyVotes {
		constants.price_4_big = _value;
	}
	
	function setPrice4Small(uint _value) onlyVotes {
		constants.price_4_small = _value;
	}
	
	function setPrice4Ticket(uint _id, uint _value) onlyVotes {
		games[_id].price = _value;
	}
		
	function changeMainContract(address _address) onlyVotes {
		contracts.users.setMainAddress(_address);
		contracts.ballot.setMainAddress(_address);
		for (uint i = 1; i < games_length + 1; i++) {
			games[i].game_address.call(bytes4(sha3("setMainAddress(address)")), _address);
		}
	}
	
	function changeVoteContract(address _address) onlyVotes {
		contracts.ballot = K_Ballot(_address);
		contracts.ballot_address = _address;
	}
	
	function setSmallLimit(uint _value) onlyVotes {
		contracts.users.setSmallLimit(_value);
	}
	
	function setBigLimit(uint _value) onlyVotes {
		contracts.users.setBigLimit(_value);
	}
	
	function turnGame(uint _id, uint _value) onlyVotes {
		games[_id].active = _value;
	}
	
	function getPlayerParents(address _address) constant returns (address[8] ret_parents) {
		return contracts.users.getPlayerParents(_address);
	}
	
	function getPrize (uint _id, uint _value) constant returns (uint) {
		if (_value == 2) return games[_id].price;
		if (_value == 3) return games[_id].price * 3;
		if (_value == 7) return games[_id].price + games[_id].price / 100 * 70;
	}
	
	function getSafeWallet () constant returns (address) {
		return constants.s_wallet;
	}
	
	function initGame(uint _id) onlyAdmin {
		games[_id].game_address.call(bytes4(sha3("startTheParty()")));
	}
	
	function() {}
}

contract K_Ballot {
	function setMainAddress(address _address) {
	
	}
}