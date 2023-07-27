`timescale 1ns/1ps

module clock_gen #(parameter FREQ =1, /*in KHz*/
                             PHASE=0, /*in degrees*/
                             DUTY =50 /*in percentage*/)
                  (enable, clk);
input wire enable;
output reg clk;


real clk_pd     = 1.0/(FREQ * 1e3) * 1e9;   // convert to ns
real clk_on     = DUTY/100.0 * (1.0/(FREQ * 1e3) * 1e9);
real clk_off    = (100.0 - DUTY) / 100.0 * (1.0/(FREQ * 1e3) * 1e9);
real quarter    = (1.0/(FREQ * 1e3) * 1e9) /4;
real start_dly  = ((1.0/(FREQ * 1e3) * 1e9)/4) * PHASE/90;

reg start_clk;


initial begin
  $display("FREQ      = %0d kHz", FREQ);
  $display("PHASE     = %0d deg", PHASE);
  $display("DUTY      = %0d %%", DUTY);

  $display("PERIOD    = %0.3f ns", clk_pd);
  $display("CLK_ON    = %0.3f ns", clk_on);
  $display("CLK_OFF   = %0.3f ns", clk_off);
  $display("QUARTER   = %0.3f ns", quarter);
  $display("START_DLY = %0.3f ns", start_dly);
end

initial begin
  clk <= 0;
  start_clk <= 0;
end

// When clock is enabled, delay driving the clock to one in order
// to acheive the phase effect. start_dely is configured to the
// correct delay for the configured phase. When enable is 0,
// allow engough time to complete the current clock period.
always @(posedge enable or negedge enable) begin
  if (enable) begin
    #(start_dly) start_clk = 1;
  end else begin
    #(start_dly) start_clk = 0;
  end
end

// Achieve duty cycle by a skewed clock on/off time and let this
// run as long as the clocks are turned on.
always @(posedge start_clk) begin
  if (start_clk) begin
    clk = 1;
    while (start_clk) begin
      #(clk_on)   clk = 0;
      #(clk_off)  clk = 1;
    end
    clk = 0;
  end
end
endmodule


