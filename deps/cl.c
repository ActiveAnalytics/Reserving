/*

COPYRIGHT (C) 2014 CHIBISI CHIMA-OKEREKE

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

#include <stdio.h>
#include <math.h>

/* stage one: calculates the factors, sigmas, var_f, ... */
void stage_one(double *vec, double *fact, double *sigmas, double *var_f, int p, double *Cik, double *Cik1_Cik, double *ECik, double *col_sums)
{
	int j, m;
	double cik, cik_1, sigmacum;
	for(j = 0; j < p - 1; ++j)
	{
		col_sums[0] = 0.; col_sums[1] = 0., sigmacum = 0;
		for(m = 0; m < (p - (j + 1)); ++m)
		{
			//printf("j, m: %d, %d\n", j, m);
			cik = vec[(m + j*p)];
			cik_1 = vec[(m + (1 + j)*p)];
			Cik[m] = cik;
			Cik1_Cik[m] = cik_1/cik;
			col_sums[0] += cik;
			col_sums[1] += cik_1;
		}
		fact[j] = col_sums[1]/col_sums[0];
		ECik[j] = col_sums[0];
		/* We now sum to calculate the sigma_k */
		for(m = 0; m < (p - (j + 1)); ++m)
		{
			sigmacum += Cik[m]*pow((Cik1_Cik[m] - fact[j]), 2);
		}
		sigmas[j] = sigmacum/(p - j - 2);
	}
	sigmas[p-2] = fmin(pow(sigmas[p-3], 2)/sigmas[p-4], fmin(sigmas[p-4], sigmas[p-3]));
	for(j = 0; j < p - 1; ++j)
	{
		var_f[j] = sigmas[j]/ECik[j]; // factor variance
	}
}

/* stage two: completes the triangle, calculates mse(R), reserve */
void stage_two(double *vec, double *fact, int p, double *sigmas, double *mseR, double *res, double *ECik)
{
	int i, j, k;
	double mse_cum;
	for(i = p - 1; i > 0; --i)// iterates downwards across rows
	{
		mse_cum = 0.;
		for(j = 0; j < p - i; ++j)// iterates forwards across columns
		{
			k = p*i + (p - i) + j*p;
			//printf("i, j, k: %d, %d, %d\n", i, j, k);
			vec[k] = vec[k - p]*fact[i+j-1];
			//mse_cum += (j < (p-i-1) ? (sigmas[i + j - 1]/pow(fact[i + j - 1], 2))*((1/vec[k - p]) + (1/ECik[i + j - 1])): 0.);
			mse_cum += (sigmas[i + j - 1]/pow(fact[i + j - 1], 2))*((1/vec[k - p]) + (1/ECik[i + j - 1]));
		}
		mseR[p - i] = pow(vec[k], 2)*mse_cum; // mean squared error
		res[p - i] = vec[k] - vec[p*i - i]; // reserve
	}
}

/* stage three: calculates the mse of the triangle */
void stage_three(double *p_c, double *sigmas, double *mseR, double *fact, double *ECik, double *tmseR, int p)
{
	int i, j, k;
	double term1, term2;
	for(i = 1; i < p; ++i)
	{
		term1 = term2 = 0;
		for(j = i + 1; j < p; ++j)
		{
			term1 += p_c[j];
		}
		term1 *= p_c[i];
		for(k = p - 1 - i; k < p - 1; ++k)
		{
			term2 += (2.*sigmas[k]/pow(fact[k], 2))/ECik[k];
		}
		tmseR[0] += mseR[i] + term1*term2;
	}
}

