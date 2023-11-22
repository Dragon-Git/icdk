
`ifndef TB__SV
`define TB__SV
module tb();
    import uvm_pkg::*;
    `include "uvm_macros.svh"
% for pkg in import_pkgs:
    import ${pkg}::*;
% endfor

    // Clock Generation
    int period = 10;
    reg clk = 1'b0;
    always begin
      uvm_config_db#(int)::wait_modified(null, "*","period");
      void'(uvm_config_db#(int)::get(null, "", "period", period));
    end
    always #(period/2) clk = ~clk;

    // Reset Delay Parameter
    int rst_delay = 50;
    reg rst_n = 1'b0;
    always begin
      uvm_config_db#(int)::wait_modified(null, "*","rst_delay");
      void'(uvm_config_db#(int)::get(null, "", "rst_delay", rst_delay));
    end
    initial #(rst_delay) rst_n = 1'b1;

    // ToDo: Include Dut instance here
    // dut my_dut(.clk          (clk               ),
    //        .rst_n        (rst_n             ),
    //        .bus_cmd_valid(b_if.bus_cmd_valid), 
    //        .bus_op       (b_if.bus_op       ), 
    //        .bus_addr     (b_if.bus_addr     ), 
    //        .bus_wr_data  (b_if.bus_wr_data  ), 
    //        .bus_rd_data  (b_if.bus_rd_data  ), 
    //        .rxd          (input_if.data     ),
    //        .rx_dv        (input_if.valid    ),
    //        .txd          (output_if.data    ),
    //        .tx_en        (output_if.valid   ));

    typedef virtual ${if_name} vif;
    ${if_name} mst_if(clk, rst_n);
    ${if_name} slv_if(clk, rst_n);
    ${if_name} ctrl_if(clk, rst_n);

    initial begin
        uvm_config_db# (vif)::set(null,"*","if",mst_if);
        run_test();
    end

endmodule : tb

`endif // TB__SV