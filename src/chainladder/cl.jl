# COPYRIGHT (C) 2014 CHIBISI CHIMA-OKEREKE
# 
# MIT License
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

#const libname = joinpath(joinpath(Pkg.dir(), "Reserving", "deps"), "libchainladder")

path = joinpath(Pkg.dir(), "Reserving", "deps")
fnames = ["libchainladder.so", "libchainladder.dylib", "libchainladder.dll"]
libchainladder = ""
found = false
for fname in fnames
	if !found
		libchainladder = Base.find_in_path(joinpath(path, fname))
		if isfile(libchainladder)
			found = true
			break
		end
	end
end

const libname = libchainladder

# chain ladder object with default constructor for 1D flattened triangle
type CL
	tri::Array{Float64,1} # This is a flattened claims triangle
	p::Int64 # The number of rows/columns in the triangle
	f::Array{Float64, 1} # Dev factors
	f_se::Array{Float64, 1} # standard error of dev factors
	sigma::Array{Float64, 1} # sigmas
	res::Array{Float64, 1} # reserve
	res_se::Array{Float64, 1} # reserve standard error
	tres_se::Float64 # total reserve standard error
	function CL(tri)
		tri = tri[:]
		p = int(sqrt(length(tri)))
		f = zeros(p - 1)
		f_se = zeros(p - 1)
		sigma = zeros(p - 1)
		res = zeros(p)
		res_se = zeros(p)
		tres_se = 0.
		new(tri, p, f, f_se, sigma, res, res_se, tres_se)
	end
end

# indexing of the items in the CL object
function Base.getindex(cl::CL, ind::Int64)
	if ind == 1
		return tri(cl)
	elseif ind == 2
		return cl.p
	elseif ind == 3
		return cl.f'
	elseif ind == 4
		return cl.f_se'
	elseif ind == 5
		return cl.sigma'
	elseif ind == 6
		return cl.res'
	elseif ind == 7
		return cl.res_se'
	elseif ind == 8
		return cl.tres_se
	end
end

# constructor for chain ladder object with matrix (2D array)
CL(tri::Array{Float64, 2}) = CL(tri[:])

# copy constructor for chain ladder
function Base.copy(cl::CL)
	newcl = CL(cl.tri)
	newcl.f = cl.f[:]
	newcl.f_se = cl.f_se[:]
	newcl.sigma = cl.sigma[:]
	newcl.res = cl.res[:]
	newcl.res_se = cl.res_se[:]
	newcl.tres_se = cl.tres_se
	return newcl
end

# accessor function gets the triange from a chain ladder object
function tri(cl::CL)
	return reshape(cl.tri, (cl.p, cl.p))
end

# function to carry out the chain ladder algorithm: type default to a chain ladder object of the kind described in:
#	Distribution-free calculation of the standard error of chain ladder reserve estimates, by Thomas Mack, ASTIN Bulletin, Vol. 23, No. 2, 1993
function chainladder!(cl::CL)
	Cik = zeros(cl.p - 1)
	Cik1_Cik = zeros(cl.p - 1)
	ECik = zeros(cl.p - 1)
	col_sums = zeros(2)
	tres_se = zeros(1)
	ccall((:stage_one, libname), Void, (Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Int64, 
		Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}), pointer(cl.tri), pointer(cl.f), pointer(cl.sigma), pointer(cl.f_se), 
		cl.p, pointer(Cik), pointer(Cik1_Cik), pointer(ECik), pointer(col_sums))
	ccall((:stage_two, libname), Void, (Ptr{Float64}, Ptr{Float64}, Int32, Ptr{Float64}, Ptr{Float64},
		Ptr{Float64}, Ptr{Float64}), pointer(cl.tri), pointer(cl.f), cl.p, pointer(cl.sigma), pointer(cl.res_se), pointer(cl.res), pointer(ECik))
	p_c = reshape(cl.tri, (cl.p, cl.p))[:,cl.p]
	ccall((:stage_three, libname), Void, (Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, 
		Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Int32), pointer(p_c), pointer(cl.sigma), pointer(cl.res_se), 
		pointer(cl.f), pointer(ECik), pointer(tres_se), cl.p)
	cl.sigma = sqrt(cl.sigma)
	cl.res_se = sqrt(cl.res_se)
	cl.tres_se = sqrt(tres_se[1])
	return cl
end

# function does not overwrite the chain ladder object
function chainladder(cl::CL)
	cl = copy(cl)
	Cik = zeros(cl.p - 1)
	Cik1_Cik = zeros(cl.p - 1)
	ECik = zeros(cl.p - 1)
	col_sums = zeros(2)
	tres_se = zeros(1)
	ccall((:stage_one, libname), Void, (Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Int64, 
		Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}), pointer(cl.tri), pointer(cl.f), pointer(cl.sigma), pointer(cl.f_se), 
		cl.p, pointer(Cik), pointer(Cik1_Cik), pointer(ECik), pointer(col_sums))
	ccall((:stage_two, libname), Void, (Ptr{Float64}, Ptr{Float64}, Int32, Ptr{Float64}, Ptr{Float64},
		Ptr{Float64}, Ptr{Float64}), pointer(cl.tri), pointer(cl.f), cl.p, pointer(cl.sigma), pointer(cl.res_se), pointer(cl.res), pointer(ECik))
	p_c = reshape(cl.tri, (cl.p, cl.p))[:,cl.p]
	ccall((:stage_three, libname), Void, (Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, 
		Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Int32), pointer(p_c), pointer(cl.sigma), pointer(cl.res_se), 
		pointer(cl.f), pointer(ECik), pointer(tres_se), cl.p)
	cl.sigma = sqrt(cl.sigma)
	cl.res_se = sqrt(cl.res_se)
	cl.tres_se = sqrt(tres_se[1])
	return cl
end

# Function overload for 2D array object
function chainladder(cl::Array{Float64, 2})
	cl = CL(cl)
	chainladder!(cl)
	return cl
end

# Function overload for a 1D array
function chainladder(cl::Array{Float64, 1})
	cl = CL(cl)
	chainladder!(cl)
	return cl
end

# show function for the chain ladder object
function Base.show(io::IO, cl::CL)
	item1 = "Claims triangle of size: " * string(cl[2])
	clNames = [item1, "Size:", "Dev Factors:", "Dev Factor S.E.", "Sigma", "Reserve", "Reserve S.E."]
	for i in [1, 3:7]
		println(io, clNames[i])
		i != 1? show(io, cl[i]) : show(io, tri(cl))
		print(io, "\n\n")
	end
	println(io, "Total Reserve S.E.")
	show(io, cl.tres_se)
	print(io, '\n')
end


