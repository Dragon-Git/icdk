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
