using Reserving
using Base.Test

# write your own tests here
tr1 = chainladder(mtr1);

# check the type of the object
@test typeof(tr1) <: CL

# make sure that we have the correct number of items in the object
@test length(tr1) == 8

# checking the names of the object
@test names(tr1) = [:tri,  :p,  :f,  :f_se,  :sigma,  :res,  :res_se,  :tres_se]

# test that the correct factors are returned (matching Mack's paper)
devf = [i > 3 ? round(tr1[3][i], 3) : round(tr1[3][i], 2) for i in 1:length(tr1[3])]
@test devf == [3.49, 1.75, 1.46, 1.174, 1.104, 1.086, 1.054, 1.077, 1.018]

# test that the correct sigma values are obtained
rounds = [0, 1, 1, 1, 1, 2, 3, 2, 3]
sigmas = (tr1.sigma.^2)/1000
sigmas = [round(sigmas[i], rounds[i]) for i in 1:(tr1.p - 1)]
@test sigmas == [160, 37.7, 42.0, 15.2, 13.7, 8.19, .447, 1.15, .447]

# test that the correct reserves are returned
@test round(tr1.res/1000)[2:end] == [95., 470, 710, 985, 1419, 2178, 3920, 4279, 4626]

# test that the correct standard errors are returned
@test round(tr1.res_se/1000, 2) == [0.0, 75.54, 121.7, 133.55, 261.41, 411.01, 558.32, 875.33, 971.26, 1363.15]

# test that the correct total standard error is obtained
@test round(tr1.tres_se) == 2.447095e6


