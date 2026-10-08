#!/bin/sh
# Compiler wrapper for XeZIM's export-trampoline link.
#
# XeZIM builds the trampoline by spawning a bare "cc" (resolved through
# PATH; $CC is ignored) as "cc -m64 -fPIC -shared". Two things go wrong
# without this wrapper:
#
#  * -m64 is an x86-ism — non-x86 compilers reject it, the trampoline
#    link fails, every SV DPI export (e.g. UVM's m__uvm_report_dpi)
#    stays unresolved, and --dpi-lib libraries can no longer be loaded
#    (RTLD_NOW relocation error).
#  * on macOS, ld64 rejects the undefined __xezim_dpi_export_dispatch
#    (defined in the xezim binary) in a dylib, which Linux's -shared
#    tolerates — same fix uvm_bridge uses.
#
# The real compiler comes in as $XEZIM_REAL_CC (an absolute path,
# captured before this wrapper's directory is put on PATH, so this
# script can never recurse into itself).
if [ -z "$XEZIM_REAL_CC" ]; then
    echo "ccwrap: XEZIM_REAL_CC is not set" >&2
    exit 1
fi

echo "[ccwrap] $*" >&2

# Rebuild the argument list without -m64, preserving each argument
# exactly: the original argv stays in positions 1..n while the filtered
# copies are appended behind it, then the originals are shifted off.
n=$#
i=1
while [ "$i" -le "$n" ]; do
    eval "a=\$$i"
    if [ "$a" != "-m64" ]; then
        set -- "$@" "$a"
    fi
    i=$((i + 1))
done
i=1
while [ "$i" -le "$n" ]; do
    shift
    i=$((i + 1))
done

case "$(uname)" in
    Darwin) set -- "$@" -Wl,-U,___xezim_dpi_export_dispatch ;;
esac

exec "$XEZIM_REAL_CC" "$@"
