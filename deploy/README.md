# Deploy

## How to start

Install hardhat by simply typing `npm hardhat install`
When installation is done, compile contracts `npx hardhat compile`
To deploy contracts locally: `npx hardhat deploy` -- script will deploy the gate first, then storage proof verifier with verifier and gate address. 
Verifier is hard-set in the script(you can change in manually). Gate deploys first, and then its address is used as input for storage verier.

## Deploy on Sepolia

First, you will need test ETH on the Sepolia network. You can use this (https://sepoliafaucet.com/) faucet or any other you want.

Then you will need your private key that must be inserted in `hardhat.config.ts` file. Do not reveal your private key to anyone!

You will need url. You can use Alchemy, Go to the website https://dashboard.alchemy.com/ and create your application on the Sepolia network. Then derive the HTTPS API key and insert it in `hardhat.config.ts` file. 

Then you can deploy on Sepolia using the following command: `npx hardhat deploy --network sepolia`.
Be advised deployment on the test network can be a bit time-consuming.