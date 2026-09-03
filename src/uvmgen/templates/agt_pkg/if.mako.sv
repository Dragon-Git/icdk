<%block name="main">\
`ifndef ${agent_name.upper()}_IF__SV
`define ${agent_name.upper()}_IF__SV

`ifdef VERILATOR
// Sim-friendly variant: drops the clocking blocks and the
// 'input bit' port-list keywords that the cycle-based sim rejects
// when the interface is later included by a package. Modports are
// kept so generated drivers/monitors can still reference them by name.
interface ${agent_name}_if (bit clk, bit rst);

   parameter setup_time = 5/*ns*/;
   parameter hold_time  = 3/*ns*/;

   logic       async_en;
   logic       async_rdy;

   modport master(input clk,
                  output async_en,
                  input  async_rdy,
                  input  rst);

   modport slave(input clk,
                 input  async_en,
                 output async_rdy,
                 input  rst);

   modport passive(input clk,
                   input async_en,
                   input async_rdy,
                   input rst);

endinterface: ${agent_name}_if

`else
interface ${agent_name}_if (input bit clk, input bit rst);

   // ToDo: Define default setup & hold times

   parameter setup_time = 5/*ns*/;
   parameter hold_time  = 3/*ns*/;

   // ToDo: Define synchronous and asynchronous signals as wires

   logic       async_en;
   logic       async_rdy;

   // ToDo: Define one clocking block per clock domain
   //       with synchronous signal direction from a
   //       master perspective

   clocking mck @(posedge clk);
      default input #setup_time output #hold_time;

      // ToDo: List the synchronous signals here

   endclocking: mck

   clocking sck @(posedge clk);
      default input #setup_time output #hold_time;

      // ToDo: List the synchronous signals here

   endclocking: sck

   clocking pck @(posedge clk);
      default input #setup_time output #hold_time;

      //ToDo: List the synchronous signals here

   endclocking: pck

   modport master(clocking mck,
                  output async_en,
                  input  async_rdy);

   modport slave(clocking sck,
                 input  async_en,
                 output async_rdy);

   modport passive(clocking pck,
                   input async_en,
                   input async_rdy);

endinterface: ${agent_name}_if
`endif // !VERILATOR

`endif // ${agent_name.upper()}_IF__SV
</%block>