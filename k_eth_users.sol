// contract - user storage (wallet, tokens, user2user structure, shareholders)
contract K_Users2 { 
	// constants
	struct K_Users_Constants {
		uint big_limit; 	// kibits tokens
		uint small_limit;	// partners limit
		uint big_sold; 		// kibits sold
		uint small_sold;	// partner tokens sold
		address k_address;	// main proxy contract
		K_Eth_v5 k;
	}
	
	// user data	
	struct K_Users_User {
		uint shareholder;					// if user is shareholder 
		uint big;							// amount of kibits 2 user
		uint small;							// if user is partner
		uint partner_type;					// 0 - new, 1 - registered before platform start
		string username;					// login
		uint[8] partner_parents;			// parents-partners structure for 7 levels
		uint[8] partner_parents_level;		// user have %q% partners at level of 7
		uint[8] player_parents;				// parents-players structure for 7 levels
		uint[8] player_parents_level;		// user have %q% players at level of 7
	}
	
	K_Users_Constants public constants;
	
	mapping (string => address) username2address; // to get partner wallet from username
	
	mapping (address => uint) address2id; 	// to get user id from user wallet
	mapping (uint => address) id2address; 	// to get user wallet from id
	uint id_length; 						// length of id-address mapping (iterations)
	
	mapping (uint => K_Users_User) users;
	
	mapping (address => uint) partner;
	mapping (address => uint) player;
	
	modifier mainContract { if (msg.sender != constants.k_address) throw; _ } // only main proxy contract can do this
	
	function K_Users2 (address _k) {
		constants.big_limit = 100000000;
		constants.small_limit = 25000;
		constants.k = K_Eth_v5(_k);
		constants.k_address = _k;
		
		// root user
		id_length = 1;
		address2id[msg.sender] = id_length; 
		id2address[id_length] = msg.sender;	
		username2address["mralfredwooden"] = msg.sender;	
		users[id_length].shareholder += 1000;			
		users[id_length].username = "mralfredwooden";	
		partner[msg.sender] += 1;
		player[msg.sender] += 1;
		
		// will be next user
		id_length += 1;
	}
	
	// if we change main proxy contract, the old one can rewrite this;
	function setMainAddress(address _k) mainContract {
		constants.k_address = _k;
		constants.k = K_Eth_v5(_k);
	}
	
	// link shareholder token to user
	function setShareholder(address _shareholder, uint _value) {
		// only another shareholder
		if (getShareholder(msg.sender) == 0) throw;
		if (users[address2id[msg.sender]].shareholder < _value) throw;
		if (users[address2id[_shareholder]].shareholder + _value < users[address2id[_shareholder]].shareholder) throw; 
		users[address2id[msg.sender]].shareholder -= _value;
		users[address2id[_shareholder]].shareholder += _value;
    }
	
	// check if user is shareholder
	function getShareholder (address _address) constant returns (uint ret_value) {
		return users[address2id[_address]].shareholder;
	}
	
	// partner registration
	function registerPartner (address _address, string _username, string _parentname, uint _type) mainContract {
		uint index = 0;
		// there are no partners with this wallet
		if (partner[_address] == 0 && partner[username2address[_parentname]] > 0) {
			address2id[_address] = id_length; 
			id2address[id_length] = _address;
			partner[_address] += 1;
			if (username2address[_username] == 0) {
				username2address[_username] = _address;
			}
			users[id_length].partner_type = _type;
			users[id_length].username = _username;
			// first parent
			users[id_length].partner_parents[0] = address2id[username2address[_parentname]];				
			users[address2id[username2address[_parentname]]].partner_parents_level[0] += 1;
			// other parents are parents of first one
			for (uint i = 0; i < 7; i++) {
				if (users[address2id[username2address[_parentname]]].partner_parents[i] != 0) {
					index += 1;
					users[id_length].partner_parents[index] = users[address2id[username2address[_parentname]]].partner_parents[i];
					users[users[address2id[username2address[_parentname]]].partner_parents[i]].partner_parents_level[index] += 1;
				}				
			}
			id_length += 1;			
		} else {
			throw;
		}
	}
	
	function registerPlayer (address _address, string _username, string _parentname) mainContract {
		uint index = 0;
		bool count_player = false;
		// there are no partners with this wallet
		if (player[_address] == 0 && player[username2address[_parentname]] > 0) {
			// player could be also a partner, partner always a player
			if (partner[_address] == 0) {
				address2id[_address] = id_length; 
				id2address[id_length] = _address;
				id_length += 1;	
			}
			
			player[_address] += 1;
			if (username2address[_username] == 0) {
				username2address[_username] = _address;
			}
			users[address2id[_address]].username = _username;					
			// if player is not a partner
			if (partner[_address] == 0) {	
				users[address2id[_address]].player_parents[0] = address2id[username2address[_parentname]];	
				if (checkPartner(username2address[_parentname]) && !count_player) {
					users[address2id[username2address[_parentname]]].player_parents_level[0] += 1;
					count_player = true;
				} else {
					for (uint i = 0; i < 7; i++) {
						if (users[address2id[username2address[_parentname]]].player_parents[i] != 0) {
							index += 1;
							users[address2id[_address]].player_parents[index] = users[address2id[username2address[_parentname]]].player_parents[i];
							if (checkPartner(id2address[users[address2id[username2address[_parentname]]].player_parents[i]]) && !count_player) {
								users[users[address2id[username2address[_parentname]]].player_parents[i]].player_parents_level[index] += 1;
								break;
							}
						}				
					}	
				}	
			// if he is	
			} else {
				// partner-player is self parent, he gets bonuses from himself;
				users[address2id[_address]].player_parents[0] = address2id[_address];	
				users[address2id[_address]].player_parents_level[0] += 1;
				count_player = true;
			}				
		} else {
			throw;
		}
	}
	
	// somebody get kibits
	function setBig(address _address, uint _value) mainContract {
		constants.big_limit -= _value;
		constants.big_sold += _value;
		users[address2id[_address]].big += _value;
	}
	
	// somebody became a partner
	function setSmall(address _address, uint _value) mainContract {
		constants.small_limit -= _value;
		constants.small_sold += _value;
		users[address2id[_address]].small += _value;
	}
	
	// kibits from one person to another (for buying and selling in the future)
	function transferBig(address _donor, address _recipient, uint _value) mainContract {
		users[address2id[_donor]].big -= _value;
		users[address2id[_recipient]].big += _value;
	}
	
	// if player becomes partner (future opportunity)
	function setPartner(address _address) mainContract {
		partner[_address] += 1;
	}
	
	// for start period people should change automatically generated wallets for manually created by themselves
	function changeWallet(address _donor, address _recipient) mainContract {
		if (address2id[_donor] > 0) {
			uint id = address2id[_donor];
			id2address[id] = _recipient;
			address2id[_recipient] = id;
			username2address[users[id].username] = _recipient;
			delete address2id[_donor];
			delete partner[_donor];
			partner[_recipient] += 1;
		}
	}
	
	function getSmall (address _address) constant returns (uint ret_small) {
		return users[address2id[_address]].small;
	}
	
	function getBig (address _address) constant returns (uint ret_big) {
		return users[address2id[_address]].big;
	}
	
	// if it was decided to change total amount of kibits
	function setBigLimit(uint _value) mainContract {
		constants.big_limit = _value;
	}
	
	// if it was decided to change total amount of partners
	function setSmallLimit(uint _value) mainContract {
		constants.small_limit = _value;
	}
	
	function getBigLimit() constant returns (uint ret_value) {
		return constants.big_limit;
	}
	
	function getSmallLimit() constant returns (uint ret_value) {
		return constants.small_limit;
	}
	
	function getBigSold() constant returns (uint ret_value) {
		return constants.big_sold;
	}
	
	function getSmallSold() constant returns (uint ret_value) {
		return constants.small_sold;
	}
	
	// new partner, or registere before crowdsale
	function getPartnerType(address _address) constant returns (uint ret_type) {
		return users[address2id[_address]].partner_type;
	}
	
	// exist or not
	function checkUsername(string _username) constant returns (bool ret_value) {
		if (username2address[_username] > 0) {return true;}
		else {return false;}
	}
	
	// total amount of related partners
	function getPartners() constant returns (uint count) {
		uint q = 0;
		for (uint i = 0; i < 7; i++) {
			q += users[address2id[msg.sender]].partner_parents_level[i];
		}
		return q;
	}
	
	// total amount of related players
	function getPlayers() constant returns (uint count) {
		uint q = 0;
		for (uint i = 0; i < 7; i++) {
			q += users[address2id[msg.sender]].player_parents_level[i];
		}
		return q;
	}
	
	// amount of related partners on specified level
	function getPartnersPerLevel(uint _level, address _address) constant returns (uint count) {
		return users[address2id[_address]].partner_parents_level[_level - 1];
	}
	
	// amount of related players on specified level
	function getPlayersPerLevel(uint _level, address _address) constant returns (uint count) {
		return users[address2id[_address]].player_parents_level[_level - 1];
	}
	
	// if partners is shareholder
	function checkShareholder(address _possible_shareholder) constant returns (bool ret_shareholder) {
		if (users[address2id[_possible_shareholder]].shareholder > 0) return true;
		else return false;
    }
	
	// to get all 7 partners-parents of specified wallet
	function getPartnerParents(address _address) constant returns (address[8] ret_parents) {
		address[8] memory tmp_arr; 
		for(uint i = 0; i < 7; i++) {
			tmp_arr[i] = id2address[users[address2id[_address]].partner_parents[i]];
		}
		return tmp_arr;
	}
	
	// to get all 7 players-parents of specified wallet
	function getPlayerParents(address _address) constant returns (address[8] ret_parents) {
		address[8] memory tmp_arr; 
		for(uint i = 0; i < 7; i++) {
			tmp_arr[i] = id2address[users[address2id[_address]].player_parents[i]];
		}
		return tmp_arr;
	}
	
	// exist or not
	function checkPlayer(address _address) constant returns (bool ret_player) {
		if (player[_address] != 0) return true;
		else return false;
	}
	
	// exist or not
	function checkPartner(address _address) constant returns (bool ret_player) {
		if (partner[_address] != 0) return true;
		else return false;
	}
}