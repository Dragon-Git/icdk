
`ifndef TB__SV
`define TB__SV
module tb();
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ${test_pkg_name}_pkg::*;

    reg[7:0] rxd;
    reg rx_dv;
    wire[7:0] txd;
    wire tx_en;

    my_if input_if(clk, rst_n);
    my_if output_if(clk, rst_n);

    bus_if b_if(clk, rst_n);

    // ToDo: Include Dut instance here
    dut my_dut(.clk          (clk               ),
           .rst_n        (rst_n             ),
           .bus_cmd_valid(b_if.bus_cmd_valid), 
           .bus_op       (b_if.bus_op       ), 
           .bus_addr     (b_if.bus_addr     ), 
           .bus_wr_data  (b_if.bus_wr_data  ), 
           .bus_rd_data  (b_if.bus_rd_data  ), 
           .rxd          (input_if.data     ),
           .rx_dv        (input_if.valid    ),
           .txd          (output_if.data    ),
           .tx_en        (output_if.valid   ));

    // Clock Generation
    int period = 10;
    logic clk = 1'b0;
    always begin
      uvm_config_db#(int)::wait_modified(null, "*","period");
      void'(uvm_config_db#(int)::get(null, "period","period"));
    end
    always #(period/2) clk = ~clk;

    // Reset Delay Parameter
    int rst_delay = 50;
    logic rst_n = 1'b0;
    always begin
      uvm_config_db#(int)::wait_modified(null, "*","rst_delay");
      void'(uvm_config_db#(int)::get(null, "rst_delay","rst_delay"));
    end
    initial #(rst_delay) rst_n = 1'b1;

    initial begin
        run_test();
    end

endmodule : tb

`endif // TB__SV