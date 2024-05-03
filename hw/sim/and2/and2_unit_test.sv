/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

`timescale 1ns/1ps

`include "svunit_defines.svh"

import svunit_pkg::svunit_testcase;

module and2_unit_test;


/**
 * Local variables and signals
 */

svunit_testcase svunit_ut;
string name = "and2";

logic a, b, y;


/**
 * Submodules placement
 */

and2 u_and2 (
    .y,
    .a,
    .b
);


/**
 * Tasks and functions definitions
 */

function void build();
    svunit_ut = new(name);
endfunction

task setup();
    svunit_ut.setup();
endtask

task teardown();
    svunit_ut.teardown();
endtask


/**
 * Test suite definition
 */

`SVUNIT_TESTS_BEGIN

`SVTEST(a_0_b_0)
    a = 1'b0;
    b = 1'b0;
    #1;

    `FAIL_IF(y);
`SVTEST_END

`SVTEST(a_1_b_0)
    a = 1'b1;
    b = 1'b0;
    #1;

    `FAIL_IF(y);
`SVTEST_END

`SVTEST(a_0_b_1)
    a = 1'b0;
    b = 1'b1;
    #1;

    `FAIL_IF(y);
`SVTEST_END

`SVTEST(a_1_b_1)
    a = 1'b1;
    b = 1'b1;
    #1;

    `FAIL_UNLESS(y);
`SVTEST_END

`SVUNIT_TESTS_END

endmodule
