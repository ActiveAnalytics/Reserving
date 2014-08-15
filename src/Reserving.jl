module Reserving

## export methods and types
export CL, tri, chainladder, chainladder!, mtr1, mtr2, auto1

## load file
include(joinpath("chainladder", "cl.jl"))
include(joinpath("data", "data.jl"))

end # module

