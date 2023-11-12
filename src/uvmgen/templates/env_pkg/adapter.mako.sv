`ifndef ${adapter_name.upper()}__SV
`define ${adapter_name.upper()}__SV

class ${adapter_name} extends uvm_reg_adapter;

`uvm_object_utils(${adapter_name})

 function new (string name="");
   super.new(name);
 endfunction: new

 virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  ${reg_tr_name} tr;
  tr = ${reg_tr_name}::type_id::create("tr"); 
  tr.kind = (rw.kind == UVM_READ) ? ${reg_tr_name}::READ : ${reg_tr_name}::WRITE; 
  //  tr.addr = rw.addr;
  //  tr.data = rw.data;
  return tr;
 endfunction: reg2bus

 virtual function void bus2reg (uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
  ${reg_tr_name} tr;
  if (!$cast(tr, bus_item))
   `uvm_fatal("NOT_HOST_REG_TYPE", "bus_item is not correct type");
  rw.kind = tr.kind ? UVM_READ : UVM_WRITE;
  //  rw.addr = tr.addr;
  //  rw.data = tr.data;
  //  rw.status = UVM_IS_OK;
 endfunction: bus2reg

endclass: ${adapter_name}

// ${adapter_name.upper()}__SV
