// Please generate this file using the peakrdl-uvm tool.
package ral_pkg;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    class ctrl extends uvm_reg;
        `uvm_object_utils(ctrl)
        rand uvm_reg_field ctrl_field;

        function new(string name = "ctrl");
            super.new(name, 32, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            ctrl_field = uvm_reg_field::type_id::create("ctrl_field");
            ctrl_field.configure(this, 32, 0, "RW", 0, 0, 1, 0, 0);
        endfunction
    endclass

    class empty_reg_block extends uvm_reg_block;

        `uvm_object_utils(empty_reg_block)
        rand ctrl ctrl_reg;
       
        uvm_reg_map APB_map; // Block map
        function new(string name = "empty_reg_block");
            super.new(name); 
        endfunction

        //--------------------------------------------------------------------
        // build
        //--------------------------------------------------------------------
        virtual function void build();
            ctrl_reg = ctrl::type_id::create("ctrl"); 
            ctrl_reg.configure(this, null, ""); 
            ctrl_reg.build();
            // Map name, Offset, Number of bytes, Endianess)
            APB_map = create_map("APB_map", 'h0, 4, UVM_LITTLE_ENDIAN);
            APB_map.add_reg(ctrl_reg, 32'h00000000, "RW"); 
            lock_model();
        endfunction
    endclass

endpackage
