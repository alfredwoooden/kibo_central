# KIBO main Ethereum contracts

Here you can find central proxy contract and token storage contract sources.  
Due to the current restrictions on gas limit, there are capsule version, working right now.
Immediately after the lifting of the restrictions  contracts will be replaced by their full versions.

Solidity version: - **3.2**

#ABI 

Token address: 0x7c2e9b93d19a0d0d55a5515aec5b1422454eb2da

[{"constant":true,"inputs":[],"name":"getBigLimit","outputs":[{"name":"ret_value","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"_address","type":"address"}],"name":"checkPartner","outputs":[{"name":"ret_player","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_address","type":"address"},{"name":"_value","type":"uint256"}],"name":"setSmall","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_address","type":"address"},{"name":"_username","type":"string"},{"name":"_parentname","type":"string"},{"name":"_type","type":"uint256"}],"name":"registerPartner","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"getSmallSold","outputs":[{"name":"ret_value","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_donor","type":"address"},{"name":"_recipient","type":"address"}],"name":"changeWallet","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"}],"name":"setBigLimit","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_address","type":"address"}],"name":"getPartnerParents","outputs":[{"name":"ret_parents","type":"address[8]"}],"type":"function"},{"constant":true,"inputs":[],"name":"getBigSold","outputs":[{"name":"ret_value","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"_username","type":"string"}],"name":"checkUsername","outputs":[{"name":"ret_value","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_address","type":"address"}],"name":"getBig","outputs":[{"name":"ret_big","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_address","type":"address"},{"name":"_value","type":"uint256"}],"name":"setBig","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_level","type":"uint256"},{"name":"_address","type":"address"}],"name":"getPartnersPerLevel","outputs":[{"name":"count","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_k","type":"address"}],"name":"setMainAddress","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_address","type":"address"}],"name":"getSmall","outputs":[{"name":"ret_small","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"getSmallLimit","outputs":[{"name":"ret_value","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[],"name":"init","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"}],"name":"setSmallLimit","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_address","type":"address"}],"name":"getPartnerType","outputs":[{"name":"ret_type","type":"uint256"}],"type":"function"},{"inputs":[{"name":"_k","type":"address"}],"type":"constructor"}]

To get KIBIT balance, use getBig function
