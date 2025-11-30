/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 * 
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "ncosest_fc_impl.h"

namespace gr {
  namespace shfcc {

    ncosest_fc::sptr
    ncosest_fc::make(float fs, std::vector<float> freqs , int nfreqs, float eps_abs, int Neps, int calc_len)
    {
      return std::make_shared<ncosest_fc_impl>(fs, freqs, nfreqs, eps_abs, Neps, calc_len);
    }

    /*
     * The private constructor
     */
    ncosest_fc_impl::ncosest_fc_impl(float fs, std::vector<float> freqs , int nfreqs, float eps_abs, int Neps, int calc_len)
      : gr::sync_decimator("ncosest_fc",
              gr::io_signature::make(1, 1, sizeof(float) ),
              gr::io_signature::make2(2, 2, sizeof(float)*nfreqs, sizeof(gr_complex)*nfreqs ), 
              calc_len)
    {
    	d_fs = fs;
    	d_nfreqs = 2*nfreqs;
    	d_calc_len = calc_len;
    	d_neps = Neps;

    	d_freqs.resize(d_nfreqs);
    	for (int i = 0; i < d_freqs.size(); ++i)
    	{
    		if(i%2==0)
    		{
    			d_freqs.at(i) = freqs[i/2];
    		}
    		else
    		{
    			d_freqs.at(i) = -d_freqs.at(i-1);
    		}
    		fprintf(stderr, "d_freqs[%d]: %9.3f\n", i, d_freqs.at(i) );
    	}
    	linspace(d_eps,-1.f,1.f,d_neps);
    }

    /*
     * Our virtual destructor.
     */
    ncosest_fc_impl::~ncosest_fc_impl()
    {
    }

    void
    ncosest_fc_impl::linspace(vector<float> &v, const float min_val, const float max_val, const int steps)
    {
    	v.resize(steps);
    	float step = (max_val-min_val)/(steps-1);
    	v[0] = min_val;
    	for (int i = 1; i < v.size(); ++i)
    	{
    		v[i] = v[i-1] + step;
    	}
    	return;
    }

    void
    ncosest_fc_impl::calc_error(float &err, const float* in, const vector<float> &freqs)
    {
    	cx_fmat B(d_calc_len, d_nfreqs);
    	rowvec omega(d_nfreqs);

    	for (int i = 0; i < d_nfreqs; ++i)
    	{
    		omega(i) = freqs.at(i)*2.f*fdatum::pi;
    	}

    	return;
    }

    float
    mean(const float* in, int calc_len)
    {
    	float m = 0.f;
    	for (int i = 0; i < calc_len; ++i)
    	{
    		m += *in++;
    	}
    	m /= calc_len;
    	return m;
    }

    int
    ncosest_fc_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      const float  *in   = (const float*) input_items[0];
      float        *out0 = (float*)       output_items[0];
      gr_complex   *out1 = (gr_complex*)  output_items[1];

      //fprintf(stderr, "NOI: %d\n", noutput_items);
      //fprintf(stderr, "d_nfreqs: %d\n", d_nfreqs);
      
      for (int i = 0; i < noutput_items; ++i)
      {
      	for (int n = 0; n < d_nfreqs; ++n)
      	{
      		//out0[i*d_nfreqs  ] = 0.f;
      		//fprintf(stderr, "idx:%d\n", i*d_nfreqs+n);

      		//out0[i*d_nfreqs+n] = 1.f;
      		out0[i*d_nfreqs + n] = mean( in, d_calc_len);

      		//out1[i*d_nfreqs  ] = gr_complex(1.f,1.f);
      		out1[i*d_nfreqs+n] = gr_complex(1.f,1.f);
      		//out1[i*d_nfreqs + n] = gr_complex(1.f,0.f);
      	}
      	in += d_calc_len;
      }
      
      
      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */
