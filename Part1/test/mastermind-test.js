//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected
const chai = require("chai");
const path = require("path");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("Master mind for kids test", function () {
    this.timeout(100000000);

    let poseidonJs;

    before(async () => {
        poseidonJs = await buildPoseidon();
    });

    it("2nd question", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();

        // Player1 Solution & SolutionHash
        const solution1 = [1,1,3];
        const salt1 = ethers.BigNumber.from(ethers.utils.randomBytes(55));
        const solutionHash1 = ethers.BigNumber.from(
            poseidonJs.F.toObject(poseidonJs([salt1, ...solution1]))
        );
        const INPUT = {
            "pubGuessA": "1",
            "pubGuessB": "1",
            "pubGuessC": "3",
            "pubNumBlacks": "3",
            "pubNumWhites": "0",
            "pubSolnHash": solutionHash1,
            "privSolnA": "1",
            "privSolnB": "1",
            "privSolnC": "3",
            "privSalt": "55"
        }

        const witness = await circuit.calculateWitness(INPUT, true);

        console.log(witness);

        assert(Fr.eq(Fr.e(witness[0]), Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]), Fr.e(1)));
    });
});