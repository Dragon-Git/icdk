<%doc>
Interface files (`*_if.gen.sv`) are not `include`d into the package:
they are compiled as standalone sources, because an interface
declaration does not belong inside a package.
</%doc>
package ${pkg_name};
    import uvm_pkg::*;
    `include "uvm_macros.svh"
% for pkg in import_pkgs:
    import ${pkg}:*;
% endfor

    typedef class ${agent_name}_item;
    typedef class ${agent_name}_cfg;
    typedef class ${agent_name}_drv;
    typedef class ${agent_name}_mon;
    typedef class ${agent_name}_sqr;
    typedef class ${agent_name}_cov;
    typedef class ${agent_name}_mon2cov_connect;

${'\n'.join([f'`include "{f.name}"' for f in files if 'pkg' not in f.name and not f.name.endswith('_if.gen.sv')])}

endpackage: ${pkg_name}