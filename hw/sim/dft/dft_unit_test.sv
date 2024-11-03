`timescale 1ns/1ps

`include "svunit_defines.svh"

import svunit_pkg::svunit_testcase;

module dft_unit_test;

   localparam FFT_LENGTH = 8192;
   localparam FFT_DW = 16;
   localparam PL_DEPTH = 3;
   localparam FFT_N = $clog2( FFT_LENGTH );

   `include "header.sv"
   `include "simtask.sv"

   svunit_testcase svunit_ut;
   string name = "dft";

   integer i;
   integer inputReal;
   integer inputImag;
   integer fftBfpExp;

   function void build();
      svunit_ut = new(name);
      verbosity_pkg::set_verbosity(verbosity_pkg::VERBOSITY_WARNING);
   endfunction

   task setup();
      svunit_ut.setup();
   endtask

   task teardown();
      svunit_ut.teardown();
   endtask

   `SVUNIT_TESTS_BEGIN

   `SVTEST(test_dft)
         rst_reg = 1;
         autorun_reg = 1;
         fin_reg = 0;
         run_reg = 0;
         ifft_reg = 0;
         wait_clk( 10 );

         $info("status = 0x%x : IDLE/RST", status);

         rst_reg = 0;

         wait_clk( 10 );

         $info("autorun = 1");

         $info("status = 0x%x : INPUT_STREAM", status );


         for ( i = 0; i < FFT_LENGTH; i++ ) begin
      sact_istream_reg <= 1'b1;
      inputReal = ToSignedInt(
               $sin ( 2.0 * M_PI * 8 *  i / FFT_LENGTH )
               );
      inputImag = 0;

      sdw_istream_real_reg <= inputReal;
      sdw_istream_imag_reg <= inputImag;
      wait_clk( 1 );
         end // for ( i = 0; i < FFT_LENGTH; i++ )
         sact_istream_reg <= 1'b0;

         $info("status = 0x%x : RUN_FFT", status );

         while ( !done ) begin
      wait_clk( 1 );
         end

         $info("status = 0x%x : DONE", status );

         fftBfpExp = bfpexp;
         dumpFromDmaBus();

         fin_reg <= 1'b1;
         autorun_reg <= 1'b0;
         wait_clk( 1 );

         fin_reg <= 1'b0;

         $info("autorun = 0");

         wait_clk( 10 );

         $info("status = 0x%x : INPUT_STREAM", status );


         for ( i = 0; i < FFT_LENGTH; i++ ) begin
      sact_istream_reg <= 1'b1;
      inputReal = ToSignedInt(
               $sin ( 2.0 * M_PI * 32 *  i / FFT_LENGTH )
               );
      inputImag = 0;

      sdw_istream_real_reg <= inputReal;
      sdw_istream_imag_reg <= inputImag;
      wait_clk( 1 );
         end // for ( i = 0; i < FFT_LENGTH; i++ )
         sact_istream_reg <= 1'b0;

         $info("status = 0x%x : FULL_BUFFER", status );

         wait_clk( 10 );

         run_reg <= 1'b1;
         wait_clk( 1 );
         run_reg <= 1'b0;

         $info("status = 0x%x : RUN_FFT", status );

         while ( !done ) begin
      wait_clk( 1 );
         end

         $info("status = 0x%x : DONE", status );

         fftBfpExp = bfpexp;
         dumpFromDmaBus();

         $finish;
   `SVTEST_END

   `SVUNIT_TESTS_END





endmodule // testbench



