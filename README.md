# Reserving.jl

Package for carrying out actuarial reserving

# Overview

This Reserving package is a small library for carrying out reserving. At the moment it simply consists of the chain ladder function as described by the paper "Distribution-free calculation of the standard error of chain-ladder reserve estimates" by Thomas Mack ASTIN Bulletin, Vol. 23, No. 2, 1993.

# Installation

It is hoped that at some point this package will be available in the Julia repository so that it can be installed using `Pkg.add("Reserving")`. Till then the package can be unpackaged into the ".julia/v0.3/" folder holding the packages and then use

```
Pkg.build("Reserving") # to build the package
using Reserving # to load the package
```

# Data sets

There are three datasets included in this package:

Two data sets from Thomas Mack's paper mentioned in the **Overview**

```
julia> mtr1
10x10 Array{Float64,2}:
 357848.0    1.12479e6    1.73533e6    2.21827e6  …    3.60629e6    3.83352e6    3.90146e6
 352118.0    1.23614e6    2.17003e6    3.35332e6       4.91404e6    5.33909e6  NaN        
 290507.0    1.29231e6    2.21853e6    3.0e6           4.90932e6  NaN          NaN        
 310608.0    1.41886e6    2.19505e6    3.75745e6     NaN          NaN          NaN        
 443160.0    1.13635e6    2.12833e6    2.89782e6     NaN          NaN          NaN        
 396132.0    1.33322e6    2.18072e6    2.98575e6  …  NaN          NaN          NaN        
 440832.0    1.28846e6    2.41986e6    3.48313e6     NaN          NaN          NaN        
 359480.0    1.42113e6    2.8645e6   NaN             NaN          NaN          NaN        
 376686.0    1.36329e6  NaN          NaN             NaN          NaN          NaN        
 344014.0  NaN          NaN          NaN             NaN          NaN          NaN        


julia> mtr2
9x9 Array{Float64,2}:
 58046.0  127970.0  476599.0          1.02769e6  …    1.81918e6    1.90685e6    1.95011e6
 24492.0  141767.0  984288.0          2.14266e6       4.0489e6     4.11576e6  NaN        
 32848.0  274682.0       1.52264e6    3.20343e6       5.34259e6  NaN          NaN        
 21439.0  529828.0       2.9003e6     4.99902e6     NaN          NaN          NaN        
 40397.0  763394.0       2.92075e6    4.98957e6     NaN          NaN          NaN        
 90748.0  951994.0       4.21064e6    5.86648e6  …  NaN          NaN          NaN        
 62096.0  868480.0       1.9548e6   NaN             NaN          NaN          NaN        
 24983.0  284441.0     NaN          NaN             NaN          NaN          NaN        
 13121.0     NaN       NaN          NaN             NaN          NaN          NaN        

```

and paid auto claims dataset from R's ChainLadder package by Markus Gesmann, Daniel Murphy,Wayne Zhang

```
julia> auto1
10x10 Array{Float64,2}:
 101125.0  209921.0  266618.0  305107.0  327850.0  340669.0  348430.0  351193.0  353353.0  353584.0
 102541.0  203213.0  260677.0  303182.0  328932.0  340948.0  347333.0  349813.0  350523.0     NaN  
 114932.0  227704.0  298120.0  345542.0  367760.0  377999.0  383611.0  385224.0     NaN       NaN  
 114452.0  227761.0  301072.0  340669.0  359979.0  369248.0  373325.0     NaN       NaN       NaN  
 115597.0  243611.0  315215.0  354490.0  372376.0  382738.0     NaN       NaN       NaN       NaN  
 127760.0  259416.0  326975.0  365780.0  386725.0     NaN       NaN       NaN       NaN       NaN  
 135616.0  262294.0  327086.0  367357.0     NaN       NaN       NaN       NaN       NaN       NaN  
 127177.0  244249.0  317972.0     NaN       NaN       NaN       NaN       NaN       NaN       NaN  
 128631.0  246803.0     NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN  
 126288.0     NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN  
```


# Usage

## The CL object

The package consists of simply the Chain Ladder algorithm as described in the **Overview** and analysis revolves around a chain ladder `CL` object. The `CL` constructor can accept an `Array{Float64,2}` containing a claims triangle and `Array{Float64,1}` containing a claims triangle flattened to 1D. Why flattened? Because the C-code that carries out the analysis crunches 1D flattened triangles.

Here we create a `CL` object:

```
julia> ladder1 = CL(mtr1)
Claims triangle of size: 10
10x10 Array{Float64,2}:
 357848.0    1.12479e6    1.73533e6    2.21827e6  …    3.60629e6    3.83352e6    3.90146e6
 352118.0    1.23614e6    2.17003e6    3.35332e6       4.91404e6    5.33909e6  NaN        
 290507.0    1.29231e6    2.21853e6    3.0e6           4.90932e6  NaN          NaN        
 310608.0    1.41886e6    2.19505e6    3.75745e6     NaN          NaN          NaN        
 443160.0    1.13635e6    2.12833e6    2.89782e6     NaN          NaN          NaN        
 396132.0    1.33322e6    2.18072e6    2.98575e6  …  NaN          NaN          NaN        
 440832.0    1.28846e6    2.41986e6    3.48313e6     NaN          NaN          NaN        
 359480.0    1.42113e6    2.8645e6   NaN             NaN          NaN          NaN        
 376686.0    1.36329e6  NaN          NaN             NaN          NaN          NaN        
 344014.0  NaN          NaN          NaN             NaN          NaN          NaN        

Dev Factors:
1x9 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0

Dev Factor S.E.
1x9 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0

Sigma
1x9 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0

Reserve
1x10 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0

Reserve S.E.
1x10 Array{Float64,2}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0

Total Reserve S.E.
0.0
```

Notice that the various parts of the `CL` object are filled out awaiting the analysis. Even though the claims triangle looks like a `10x10` array, it is actually stored as a `100x1` array already flattened before being analysed.

## The chainladder() function

There are four ways to carry out the chainladder analysis

The first is to overwrite an existing `CL` object using the `chainladder!()` function:

```
julia> chainladder!(ladder1);
julia> ladder1
Claims triangle of size: 10
10x10 Array{Float64,2}:
 357848.0  1.12479e6  1.73533e6  2.21827e6  2.7456e6   …  3.46634e6  3.60629e6  3.83352e6  3.90146e6
 352118.0  1.23614e6  2.17003e6  3.35332e6  3.79907e6     4.64787e6  4.91404e6  5.33909e6  5.43372e6
 290507.0  1.29231e6  2.21853e6  3.23518e6  3.986e6       4.62891e6  4.90932e6  5.28515e6  5.37883e6
 310608.0  1.41886e6  2.19505e6  3.75745e6  4.02993e6     4.58827e6  4.83546e6  5.20564e6  5.29791e6
 443160.0  1.13635e6  2.12833e6  2.89782e6  3.40267e6     4.20746e6  4.43413e6  4.77359e6  4.8582e6 
 396132.0  1.33322e6  2.18072e6  2.98575e6  3.69171e6  …  4.42655e6  4.66502e6  5.02216e6  5.11117e6
 440832.0  1.28846e6  2.41986e6  3.48313e6  4.08868e6     4.90253e6  5.16665e6  5.56218e6  5.66077e6
 359480.0  1.42113e6  2.8645e6   4.17476e6  4.90054e6     5.876e6    6.19256e6  6.66663e6  6.7848e6 
 376686.0  1.36329e6  2.38213e6  3.47174e6  4.07531e6     4.8865e6   5.14976e6  5.544e6    5.64227e6
 344014.0  1.20082e6  2.09823e6  3.05798e6  3.58962e6     4.30413e6  4.53601e6  4.88327e6  4.96982e6

Dev Factors:
[3.49061,1.74733,1.45741,1.17385,1.10382,1.08627,1.05387,1.07656,1.01772]

Dev Factor S.E.
[0.219477,0.0606729,0.052809,0.0286883,0.027648,0.0226507,0.00592011,0.0116044,0.0107937]

Sigma
[400.35,194.26,204.854,123.219,117.181,90.4753,21.1333,33.8728,21.1333]

Reserve
[0.0,94633.8,469511.0,709638.0,984889.0,1.41946e6,2.17764e6,3.9203e6,4.27897e6,4.62581e6]

Reserve S.E.
[0.0,75535.0,121699.0,133549.0,261406.0,411010.0,558317.0,875328.0,971258.0,1.36315e6]

Total Reserve S.E.
2.4470948608346656e6
```

The second and third is to carry out the analysis from an `Array{Float64,2}` and an `Array{Float64,1}` object. The outputs will be mutted since you have seen this enough by now. The `[:]` below is used to flatten the 2D array.

```
chainladder(mtr1);
chainladder(mtr2[:]);
```

The last technique is to call use the `chainladder()` on a `CL` object (non-overwritten). In the example below, `ladder2` remains unwritten and the output is captured in `output`.


```
ladder2 = CL(mtr2);
output = chainladder(ladder2);
```

## Copying objects

`CL` objects can also be copied using the `copy` constructor: 

```
output2 = copy(output);
```

## Accessing the items of the `CL` object

The implementation details of the `CL` object are heald in the `chainladder\cl.jl` file. The components of the object are:

1. `tri::Array{Float64,1}` - the flattened triangle
2. `p::Int64` - the size of the triangle
3. `f::Array{Float64,1}` - development factors
4. `f_se::Array{Float64,1}` - standard error of development factors
5. `sigma::Array{Float64,1}` - sigma as described in the Thomas Mack's paper
6. `res::Array{Float64,1}` - the reserve
7. `res_se::Array{Float64,1}` - reserve standard error
8. `tres_se::Float64` - total reserve standard error

There are two ways of accessing any component of the object. The first and native is using the name:

```
julia> output.f
8-element Array{Float64,1}:
 11.1043 
  4.09227
  1.70791
  1.27592
  1.13891
  1.0687 
  1.02633
  1.02268
```

But you can also access it using the index:

```
julia> output[8]
3.7288702412577975e6
```

... use Symbolic names:

```
julia> output[:f]
8-element Array{Float64,1}:
 11.1043 
  4.09227
  1.70791
  1.27592
  1.13891
  1.0687 
  1.02633
  1.02268
```

... use String names

```
julia> output["f"]
8-element Array{Float64,1}:
 11.1043 
  4.09227
  1.70791
  1.27592
  1.13891
  1.0687 
  1.02633
  1.02268
```


There is a convenience function provided for when the use simply wants to extract the triangle from the object:

```
julia> tri(output)
9x9 Array{Float64,2}:
 58046.0  127970.0  476599.0        1.02769e6  1.36049e6  1.64731e6  1.81918e6  1.90685e6  1.95011e6
 24492.0  141767.0  984288.0        2.14266e6  2.96198e6  3.68394e6  4.0489e6   4.11576e6  4.20912e6
 32848.0  274682.0       1.52264e6  3.20343e6  4.44593e6  5.15878e6  5.34259e6  5.48328e6  5.60766e6
 21439.0  529828.0       2.9003e6   4.99902e6  6.46011e6  6.8539e6   7.32474e6  7.51764e6  7.68816e6
 40397.0  763394.0       2.92075e6  4.98957e6  5.64856e6  6.43322e6  6.87516e6  7.05622e6  7.21627e6
 90748.0  951994.0       4.21064e6  5.86648e6  7.48516e6  8.52494e6  9.11058e6  9.35051e6  9.5626e6 
 62096.0  868480.0       1.9548e6   3.33862e6  4.25982e6  4.85156e6  5.18484e6  5.32139e6  5.44209e6
 24983.0  284441.0       1.16401e6  1.98803e6  2.53657e6  2.88893e6  3.08739e6  3.16869e6  3.24057e6
 13121.0  145699.0  596240.0        1.01833e6  1.2993e6   1.47979e6  1.58145e6  1.6231e6   1.65991e6
```

# Performance

We have gone to much effort to get ensure good performance from this package. The analysis itself is carried out in `C`, the code is located in `deps/cl.c` part of the package. Not only is it written in C, but as mentioned before the triangle has been flattened to one dimension as a result the calculation is very fast indeed

Below are the summary statistics for times in *microseconds* taken to run the `chainladder` algorithm on the `mtr2` data. Bear in mind that the times include the full calculation of the items in the `CL` object.

```
ttimes = [@elapsed chainladder(mtr2) for i in 1:1000];
julia> quantile(ttimes, [0, .25, .5, .75, 1])'*1E6
1x5 Array{Float64,2}:
 2.854  2.931  3.012  3.52825  12.229

```

# Future Updates

We hope that this is just the beginning. We plan to include more reserving methods and options for the current method as time allows. The next obvious step is to expand the current chain ladder algorithm to that described by Thomas Mack's 1999 paper. For any suggestions or requests contact chibisi@activeanalytics.co.uk.


