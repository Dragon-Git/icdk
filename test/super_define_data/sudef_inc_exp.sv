/* super_define(cfg_inc.svh)
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
`include "cfg_inc.svh"
// super_define generate end
