`ifndef ${agent_name.upper()}_REG_ADAPTER__SV
`define ${agent_name.upper()}_REG_ADAPTER__SV

class ${agent_name}_reg_adapter extends uvm_reg_adapter;

`uvm_object_utils(${agent_name}_reg_adapter)

 function new (string name="${agent_name}_reg_adapter");
   super.new(name);
 endfunction: new

 virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  ${agent_name}_item tr;
  tr = ${agent_name}_item::type_id::create("tr"); 
  tr.kind = (rw.kind == UVM_READ) ? ${agent_name}_item::READ : ${agent_name}_item::WRITE; 
  //  tr.addr = rw.addr;
  //  tr.data = rw.data;
  return tr;
 endfunction: reg2bus

 virtual function void bus2reg (uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
  ${agent_name}_item tr;
  if (!$cast(tr, bus_item))
   `uvm_fatal("NOT_HOST_REG_TYPE", "bus_item is not correct type");
  rw.kind = tr.kind ? UVM_READ : UVM_WRITE;
  //  rw.addr = tr.addr;
  //  rw.data = tr.data;
  //  rw.status = UVM_IS_OK;
 endfunction: bus2reg

endclass: ${agent_name}_reg_adapter

`endif // ${agent_name.upper()}_REG_ADAPTER__SV
