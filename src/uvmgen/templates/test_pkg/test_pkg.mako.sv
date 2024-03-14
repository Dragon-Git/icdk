package ${pkg_name};
    import uvm_pkg::*;
    `include "uvm_macros.svh"

% for pkg in import_pkgs:
    import ${pkg}::*;
% endfor
<% 
    file_list = list(files)
%>
% for file in file_list:
    % if "test_builder" in file.name:
    `include "${file.name}"
    % endif
% endfor
% for file in file_list:
    % if ("pkg" not in file.name) and ("test_builder" not in file.name):
    `include "${file.name}"
    % endif
% endfor   

endpackage: ${pkg_name}