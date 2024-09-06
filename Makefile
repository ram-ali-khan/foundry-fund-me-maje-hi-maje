-include .env

build:; forge build 				# u can use this command by writing "make build" in the terminal

# use ; if want to write in same line otherwise press tab in next line and write there
# env ka kuch use krna h to :    $(<name>) 
deploy-sepolia: 
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

 

# patrick asked to copy his makefile from github. but i didn't. if you want ,you can see it from there