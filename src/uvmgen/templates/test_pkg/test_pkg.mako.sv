package ${pkg_name};
    import uvm_pkg::*;
    `include "uvm_macro.sv"

    import ${env_pkg_name}::*;
    import ${seq_lib_pkg_name}::*;
% for file in files:
    % if "pkg" not in file.name:
    `include "${file.name}"
    % endif
% endfor   

endpackage: ${pkg_name}