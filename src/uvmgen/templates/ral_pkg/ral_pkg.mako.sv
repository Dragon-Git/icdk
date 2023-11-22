// Please generate this file using the peakrdl-uvm tool.
package ral_pkg;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    class empty_reg_block extends uvm_reg_block;

        `uvm_object_utils(empty_reg_block)
        function new(string name = "empty_reg_block");
            super.new(name); 
        endfunction

    endclass

endpackage
