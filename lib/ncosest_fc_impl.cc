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
      return gnuradio::get_initial_sptr
        (new ncosest_fc_impl(fs, freqs, nfreqs, eps_abs, Neps, calc_len));
    }

    /*
     * The private constructor
     */
    ncosest_fc_impl::ncosest_fc_impl(float fs, std::vector<float> freqs , int nfreqs, float eps_abs, int Neps, int calc_len)
      : gr::sync_decimator("ncosest_fc",
              gr::io_signature::make(1, 1, sizeof(float)),
              gr::io_signature::make2(2, 2, sizeof(float)*freqs.size(), sizeof(gr_complex)*calc_len), calc_len)
    {
    	d_fs = fs;
    	d_nfreqs = nfreqs;
    	d_calc_len = calc_len;
    }

    /*
     * Our virtual destructor.
     */
    ncosest_fc_impl::~ncosest_fc_impl()
    {
    }

    int
    ncosest_fc_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      const float *in = (const float*) input_items[0];
      float *out0 = (float*) output_items[0];
      gr_complex *out1 = (gr_complex*) output_items[1];

      for (int i = 0; i < noutput_items; ++i)
      {
      	for (int n = 0; i < d_nfreqs; ++n)
      	{
      		out0[i*d_nfreqs + n] = 0.f;
      		out1[i*d_nfreqs + n] = gr_complex(0.f,0.f);
      	}
      	in += d_calc_len;
      }

      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */
