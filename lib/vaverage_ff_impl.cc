/* -*- c++ -*- */
/* 
 * Copyright 2018 Magnus Lundmark.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include <volk/volk.h>
#include <cstdio>
#include "vaverage_ff_impl.h"

namespace gr {
  namespace shfcc {

    vaverage_ff::sptr
    vaverage_ff::make(int m, size_t vlen)
    {
      return gnuradio::get_initial_sptr
        (new vaverage_ff_impl(m, vlen));
    }

    /*
     * The private constructor
     */
    vaverage_ff_impl::vaverage_ff_impl(int m, size_t vlen)
      : gr::sync_decimator("vaverage_ff",
              gr::io_signature::make(1, 1, vlen*sizeof(float)),
              gr::io_signature::make(1, 1, vlen*sizeof(float)), m)
    {
      d_vlen = vlen;
      d_m = m;
      d_alignment = volk_get_alignment();
      //set_output_multiple(d_m);

      //printf("Alignment: %d\n", d_alignment);       
    }

    /*
     * Our virtual destructor.
     */
    vaverage_ff_impl::~vaverage_ff_impl()
    {
    }

    void
    myprint(const float* in, int numel){
      for(int i=0;i<numel;i++){
        printf("v[%i] %8.3f\n", i,in[i]);
      }
      printf("\n");
    }

    int
    vaverage_ff_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      const float *in = (const float *) input_items[0];
      float *out = (float *) output_items[0];

      for (int n = 0 ; n < noutput_items ; n++){

        volk_32f_x2_add_32f(out , in  , in + d_vlen , d_vlen);
        for (int m = 2; m < d_m; m++)
        {
          volk_32f_x2_add_32f(out , out , in + m*d_vlen , d_vlen);    
        }
        volk_32f_s32f_multiply_32f( out , out , 1.0f/( (float) d_m ) , d_vlen);          
        out += d_vlen;
        in  += d_m*d_vlen;
      }
      // Tell runtime system how many output items we produced.
      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */

