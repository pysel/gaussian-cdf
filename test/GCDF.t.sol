// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GaussianCDF} from "../src/gcdf.sol";

contract GCDFTest is Test {
    GaussianCDF public gcdf;

    int256 constant precision = 10 ** 18;

    function setUp() public {} // want custom setup

    function setUpCustom(int256 mean, int256 stdDev) public {
        gcdf = new GaussianCDF(mean, stdDev);
    }

    function test_GCDF() public {
        int256 mean = 60 * precision;
        int256 stdDev = 1000 * precision;

        console.log("\nTest Case with These Parameters: ");

        console.log("\tmean: ", uint256(mean));
        console.log("\tstdDev: ", uint256(stdDev));
        console.log();

        setUpCustom(mean, stdDev);

        int256 result = gcdf.cdf(2000 * precision);
        console.log("\tX is: ", uint256(2000 * precision));
        console.log("\tResult with precision: ", uint256(result));
        console.log();

        result = gcdf.cdf(1000 * precision);
        console.log("\tX is: ", uint256(1000 * precision));
        console.log("\tResult with precision: ", uint256(result));
        console.log();

        result = gcdf.cdf(0);
        console.log("\tX is: ", uint256(0));
        console.log("\tResult with precision: ", uint256(result));

        mean = -1e19 * precision;
        stdDev = 1000 * precision;

        console.log("\nTest Case with These Parameters: ");

        console.log("\tmean: ", uint256(-mean));
        console.log("\tstdDev: ", uint256(stdDev));
        console.log();

        setUpCustom(mean, stdDev);

        result = gcdf.cdf(2000 * precision);
        console.log("\tX is: ", uint256(2000 * precision));
        console.log("\tResult with precision: ", uint256(result));
        console.log();

        result = gcdf.cdf(1000 * precision);
        console.log("\tX is: ", uint256(1000 * precision));
        console.log("\tResult with precision: ", uint256(result));

        mean = 60 * precision;
        stdDev = 1e18 * precision;

        console.log("\nTest Case with These Parameters: ");

        console.log("\tmean: ", uint256(mean));
        console.log("\tstdDev: ", uint256(stdDev));
        console.log();

        setUpCustom(mean, stdDev);

        result = gcdf.cdf(2000 * precision);
        console.log("\tX is: ", uint256(2000 * precision));
        console.log("\tResult with precision: ", uint256(result));
        console.log();

        result = gcdf.cdf(1000 * precision);
        console.log("\tX is: ", uint256(1000 * precision));
        console.log("\tResult with precision: ", uint256(result));



        // CUSTOM VALUES

        // mean = <CUSTOM-MEAN> * precision;
        // stdDev = <CUSTOM-STANDARD-DEVIATION> * precision;

        // console.log("\nTest Case with These Parameters: ");

        // console.log("\tmean: ", uint256(mean)); // NOTE: for correct visualization, if mean is negative, add a negative sign before the mean value
        // console.log("\tstdDev: ", uint256(stdDev));
        // console.log();

        // setUpCustom(mean, stdDev);

        // result = gcdf.cdf(<CUSTOM-X> * precision);
        // console.log("\tX is: ", uint256(<CUSTOM-X> * precision));
        // console.log("\tResult with precision: ", uint256(result));
        // console.log();
    }
}
