<%!
def _render_include(file_obj):
    file_name = file_obj.name
    if file_name.endswith("_if.gen.sv"):
        # The cycle-based sim can't handle interfaces inside a package.
        # Emit a macro-guarded include so other simulators (full event
        # simulators) still pull the interface into the package, but the
        # cycle sim (with the appropriate macro defined at compile time)
        # skips it and provides the interface to the top module via
        # +incdir+ instead.
        return (
            "`ifdef VERILATOR\n"
            f"    // {file_name} omitted: package-local interfaces are\n"
            "    // not supported by the cycle-based sim. The interface\n"
            "    // is passed in via +incdir+ at compile time.\n"
            "`else\n"
            f'`include "{file_name}"\n'
            "`endif"
        )
    return f'`include "{file_name}"'
%>
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

${'\n'.join([_render_include(f) for f in files if 'pkg' not in f.name])}

endpackage: ${pkg_name}