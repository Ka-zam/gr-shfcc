/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 * 
*/

#ifndef INCLUDED_SHFCC_CEXP_EST_IMPL_H
#define INCLUDED_SHFCC_CEXP_EST_IMPL_H

#include <shfcc/cexp_est.h>
#include <gnuradio/fft/fft.h>
#include <string>
#include <iostream>

using namespace std;
namespace gr {
  namespace shfcc {

    class cexp_est_impl : public cexp_est
    {
     private:
     	fft::fft_complex *d_fft;
     	float d_fs;
     	int d_calc_len;
     	gr_complex* d_cpx_data;
     	gr_complex* d_cpx_datb;
      gr_complex* SCRATCH;
     	float* d_flt_data;
     	size_t d_alignment;

     	void amest(float *freq , gr_complex *amplitude , const gr_complex *in_data  );
      void printz(const string &s,const gr_complex &x);
      void printz(const string &s, const gr_complex *x,const int N);
      void printz(const string &s, float *x,const int N);
      void printz(const string &s, int8_t *x,const int N);
      void printz(const string &s, float *x,const int rows, const int cols);

     public:
      cexp_est_impl(float fs, int calc_len);
      ~cexp_est_impl();

      // Where all the action really happens
      int work(int noutput_items,
         gr_vector_const_void_star &input_items,
         gr_vector_void_star &output_items);
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_CEXP_EST_IMPL_H */

