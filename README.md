# tinylib65

snippets of 65xx code that might be useful in more than one project

_Caveat: This is an ongoing development. API and functionality may change at any time._

## design goals

### general

* readability
* consistency
* scalability
* modularity
* fast and small

### prefered calling conventions

input values

* A
* software stack
* global module variables

output values

* A
* C (0: failed, 1: success)
* last_error (0: ok, >0: error code)
* software stack
* global module variables

register and zeropage use

* caller saved: A, tmp0, tmp1, ...
* callee saved: X, Y, r0, r1, ...

exceptions

* Y may be used as additional input or output value if documented
* zp use across functions _must_ be documented

### zeropage use

general:

* avoid private module data within zeropage
* use software stack if possible

tmp0 .. tmp7 ("scratchpad")

* caller saved
* may be overwritten by every function unless documented (!)
* may be used for parameters and return values if documented

r0 .. r7 ("registers")

* callee saved
* may be used for parameters and return values if documented (deprecated)
* w0 and w1 are aliases for r0/r1 and r2/r3

last_error

* last error code (0 for success)
