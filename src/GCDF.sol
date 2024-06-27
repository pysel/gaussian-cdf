// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";


contract GaussianCDF {
    // Immutables, to change - another contract should be instantiated
    int256 public immutable i_mean;
    int256 public immutable i_stdDev;

    // Constants
    int256 constant precision = 10 ** 18;
    int256 constant ROOT_TWO = 1414213562373095048; // wolfram alpha
    int256 constant e = 2718281828459045235; // wolfram alpha

    // Erf Constants
    int256 constant c1 = 1265512230000000000;
    int256 constant c2 = 1000023680000000000;
    int256 constant c3 = 374091960000000000;
    int256 constant c4 = 96784180000000000;
    int256 constant c5 = -186288060000000000;
    int256 constant c6 = 278868070000000000;
    int256 constant c7 = -1135203980000000000;
    int256 constant c8 = 1488515870000000000;
    int256 constant c9 = -822152230000000000;
    int256 constant c10 = 170872770000000000;

    constructor(
        int256 mean,
        int256 stdDev
    ) {
        i_mean = mean;
        i_stdDev = stdDev;
    }

    function mul(int256 x, int256 y) public pure returns (int256) {
        return x * y / precision;
    }

    function powFull(int256 base, int256 exponent) public pure returns (int256) {
        int256 result = precision;
        for (int256 i = 0; i < exponent; i++) {
            result = mul(result, base);
        }
        return result;
    }

    // function mulApprox(uint256 a, uint256 b) internal pure returns (uint256) {
    //     uint256 prec = 1e18;

    //     uint256 c_0 = a * b;
    //     uint256 c_1 = c_0 + (prec / 2);
    //     uint256 c_2 = c_1 / prec;
    //     return c_2;
    // }

    // function subSign(uint256 a, uint256 b) internal pure returns (uint256, bool) {
    //     if (a >= b) {
    //         return (a - b, false);
    //     } else {
    //         return (b - a, true);
    //     }
    // }

    // function add(uint256 a, uint256 b) internal pure returns (uint256) {
    //     uint256 c = a + b;
    //     require(c >= a, "ERR_ADD_OVERFLOW");
    //     return c;
    // }

    // function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    //     (uint256 c, bool flag) = subSign(a, b);
    //     require(!flag, "ERR_SUB_UNDERFLOW");
    //     return c;
    // }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * uint256(precision);
        require(a == 0 || c0 / a == uint256(precision), "ERR_DIV_INTERNAL"); // mul overflow
        uint256 c_1 = c0 + (b / 2);
        require(c_1 >= c0, "ERR_DIV_INTERNAL"); //  add require
        uint256 c_2 = c_1 / b;
        return c_2;
    }

    // function powApprox(uint256 base, uint256 exp, uint256 prec) internal view returns (uint256) {
    //     console.log(base);
    //     console.log(exp);
    //     // term 0:
    //     uint256 a = exp;
    //     (uint256 x, bool xneg) = subSign(base, 1e18);
    //     uint256 term = 1e18;
    //     uint256 sum = term;
    //     bool negative = false;

    //     // term(k) = numer / denom
    //     //         = (product(a - i - 1, i=1-->k) * x^k) / (k!)
    //     // each iteration, multiply previous term by (a-(k-1)) * x / k
    //     // continue until term is less than precision
    //     for (uint256 i = 1; term >= prec; i++) {
    //         uint256 bigK = i * 1e18;
    //         (uint256 c, bool cneg) = subSign(a, sub(bigK, 1e18));
    //         term = mulApprox(term, mulApprox(c, x));
    //         term = div(term, bigK);
    //         if (term == 0) break;

    //         if (xneg) negative = !negative;
    //         if (cneg) negative = !negative;
    //         if (negative) {
    //             sum = sub(sum, term);
    //         } else {
    //             sum = add(sum, term);
    //         }
    //     }

    //     return sum;
    // }

    function expTaylor(int256 x) public pure returns (int256) {
        int256 sum = 0;
        int256 curFactorial = 1;
        for (int256 i = 0; i < 10; i++) {
            if (i != 0) {
                curFactorial *= i;
            }
            int256 term = powFull(x, i) / curFactorial;
            sum += term;
        }
        return sum;
    }

    function erf(int256 x) public view returns (int256) {
        if (x < 0) {
            return 2 * 1e18 - erf(-x);
        }

        int256 z = x;
        int256 denominator = precision + z/2;

        int256 t = (precision ** 2) / denominator; // with precision
        
        // calculate power
        int256 pow = mul(-z, z) - c1 + mul(t,
                                                c2 + mul(t,
                                                    c3 + mul(t,
                                                        c4 + mul(t,
                                                            c5 + mul(t,
                                                                c6 + mul(t,
                                                                    c7 + mul(t,
                                                                        c8 + mul(t,
                                                                            c9 + mul(t,
                                                                                c10)))))))));

        bool inverse = false;
        if (pow < 0) {
            inverse = true;
            pow = -pow;
        }
        int256 eFull = powFull(e, floor(pow));
        int256 remainingPow = pow - floor(pow) * precision;


        int256 eRemainder = expTaylor(remainingPow);

        int256 exponent = mul(eFull, int256(eRemainder));

        if (inverse) {
            exponent = int(div(uint(precision), uint(exponent)));
        }

        int256 r = mul(t, exponent);
        return r;
    }

    function floor(int256 x) public pure returns (int256) {
        return x / precision;
    }

    function cdf(int256 x) public view returns (int256) {
        if (x < i_mean - 10 * i_stdDev) {
            return 0;
        }

        if (x > i_mean + 10 * i_stdDev) {
            return precision;
        }

        int256 numerator = -(x - i_mean);
        int256 denominator = i_stdDev * ROOT_TWO / precision;
        int256 z = numerator * precision / denominator;
        int256 r = erf(z) / 2;
        return r;
    }

}
