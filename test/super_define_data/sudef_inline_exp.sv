/* super_define()
<%

%>\
% for i in range(1, 11):
int cfg_${i};
% endfor

`uvm_object_utils_begin(mycfg)
% for i in range(1, 11):
`uvm_field_int(cfg_${i}, UVM_DEFAULT)
% endfor
`uvm_object_utils_end

*/
// super_define generate begin
int cfg_1;
int cfg_2;
int cfg_3;
int cfg_4;
int cfg_5;
int cfg_6;
int cfg_7;
int cfg_8;
int cfg_9;
int cfg_10;

`uvm_object_utils_begin(mycfg)
`uvm_field_int(cfg_1, UVM_DEFAULT)
`uvm_field_int(cfg_2, UVM_DEFAULT)
`uvm_field_int(cfg_3, UVM_DEFAULT)
`uvm_field_int(cfg_4, UVM_DEFAULT)
`uvm_field_int(cfg_5, UVM_DEFAULT)
`uvm_field_int(cfg_6, UVM_DEFAULT)
`uvm_field_int(cfg_7, UVM_DEFAULT)
`uvm_field_int(cfg_8, UVM_DEFAULT)
`uvm_field_int(cfg_9, UVM_DEFAULT)
`uvm_field_int(cfg_10, UVM_DEFAULT)
`uvm_object_utils_end
// super_define generate end
