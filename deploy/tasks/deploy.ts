import {task} from 'hardhat/config'
const hre = require('hardhat')
import * as fs from 'fs';

task("deploy")
    .setAction(async (taskArgs, {ethers, run}) => {

        const {deployments, getNamedAccounts} = hre;
        const {deploy} = deployments;

        // https://sepolia.etherscan.io/address/0x489dbc0762b3d9bd9843db11eecd2a177d84ba2b
        const sepoliaPlaceholderVerifierAddress = '0x489Dbc0762b3D9Bd9843Db11EECd2A177D84ba2b';

        // ===================== DEPLOY GateArgument =====================
        console.log("Deploy GateArgument...")
        let libs = [
            "template_gate0",
            "template_gate15"
            ];

        let deployedLib = {}
        for (let lib of libs) {
            await deploy(lib, {
                log: true,
            });
            deployedLib[lib] = (await hre.deployments.get(lib)).address
        }

        const gateArgument = await deploy('template_gate_argument_split_gen', {
            libraries: deployedLib,
            log: true,
        });

        // const GateArgument = await ethers.getContractFactory("template_gate_argument_split_gen");
        // const gateArgument = await GateArgument.deploy();
        await gateArgument.deployed();
        console.log("GateArgument at: ", gateArgument.address)

        // ===================== DEPLOY StorageProofVerifier =====================
        console.log("Deploy StorageProofVerifier...")
        const StorageProofVerifier = await ethers.getContractFactory("StorageProofVerifier");
        const storageProofVerifier = await StorageProofVerifier.deploy(
            sepoliaPlaceholderVerifierAddress,
            gateArgument.address
        );
        await storageProofVerifier.deployed();
        console.log("StorageProofVerifier at: ", storageProofVerifier.address)
})