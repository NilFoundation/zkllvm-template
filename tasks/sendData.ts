import {task} from 'hardhat/config'
const {getAccountVerifierParams, getFileContents} = require("./utils")

task("sendData", 
    "send beacon state verification request")
    .addParam("blob", "blob file name")
    .addParam("pubi", "public input")
    .setAction(async ({blob, pubi}, {ethers, run}) => {

        // circit params --> init params, coloms rot

        const contract = '0xf01A3a0eD039494dD2Ff409Fa398FB9dEe40D567';
        const circuit_params_filepath = './contracts/circuit_params.json';
        
        // ================== Data prep ==================

        const circuit_params_data = getAccountVerifierParams(circuit_params_filepath);
        const columns_rotations = circuit_params_data.columns_rotations;
        const init_params = circuit_params_data.init_params;

        const proof = getFileContents(blob);
        const public_input = JSON.parse(getFileContents(pubi));


        // ================== Transaction ==================

        const [owner] = await ethers.getSigners();
        const StorageProofVerifier = await ethers.getContractFactory("StorageProofVerifier")
        const stateVerifier_inst = StorageProofVerifier.attach(contract)
        const stateVerifier = await stateVerifier_inst.connect(owner)

        const tx = await stateVerifier.verifyStorageProof(
            proof, 
            init_params, 
            columns_rotations, 
            '0x' + public_input[0].root,
            '0x' + public_input[1].leaf);

        const receipt = await tx.wait()
        console.log(receipt)
})
