pragma circom 2.0.0;

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit


include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";
// Mastermind for kids
template MastermindVariation() {
    // Public inputs
    signal input pubGuessA;
    signal input pubGuessB;
    signal input pubGuessC;
    signal input pubNumBlacks;
    signal input pubNumWhites;
    signal input pubSolnHash;

    // Private inputs: the solution to the puzzle
    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;

    signal input privSalt;

    // Output
    signal output solnHashOut;

    var nb = 0;
    component equalNb[9];
    
    var guess[3] = [pubGuessA, pubGuessB, pubGuessC];
    var soln[3] =  [privSolnA, privSolnB, privSolnC];

    var nw = 0;

    // Count white pegs
    // block scope isn't respected, so k and j have to be declared outside
    var k = 0;
    var j = 0;
    for (j=0; j<3; j++) {
        for (k=0; k<3; k++) {
            // the && operator doesn't work
            equalNb[3*j + k] = IsEqual();
            equalNb[3*j + k].in[0] <== guess[j];
            equalNb[3*j + k].in[1] <== soln[j];
            nw += equalNb[3*j + k].out;
            if (j == k) {
                nw -= equalNb[3*j + k].out;
                nb += equalNb[3*j + k].out;
            }
        }
    }

     //nb === pubNumBlacks ;
    // Create a constraint around the number of black pegs
    component equalBlack = IsEqual();
    equalBlack.in[0] <== pubNumBlacks;
    equalBlack.in[1] <== nb;
    equalBlack.out === 1;
    
    // Create a constraint around the number of white pegs
    component equalWhite = IsEqual();
    equalWhite.in[0] <== pubNumWhites;
    equalWhite.in[1] <== nw;
    equalWhite.out === 1;

    // Verify that the hash of the private solution matches pubSolnHash
    // via a constraint that the publicly declared solution hash matches the
    // private solution witness

    component poseidon = Poseidon(4);
    poseidon.inputs[0] <== privSalt;
    poseidon.inputs[1] <== privSolnA;
    poseidon.inputs[2] <== privSolnB;
    poseidon.inputs[3] <== privSolnC;

    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;
}

component main = MastermindVariation();