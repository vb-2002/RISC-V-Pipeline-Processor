
module top_tb;

    logic clk;
    logic rst;

    // Instantiate the DUT (Design Under Test)
    top uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generator: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset sequence
    initial begin
        rst = 1;
        #15;
        rst = 0;
    end

    // Simulation duration
    initial begin
        #1000;
        $finish;
    end

    // VCD waveform dump
    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, top_tb);
    end

endmodule