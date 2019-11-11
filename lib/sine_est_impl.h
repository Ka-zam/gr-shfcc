/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 */

#ifndef INCLUDED_SHFCC_SINE_EST_IMPL_H
#define INCLUDED_SHFCC_SINE_EST_IMPL_H

#include <shfcc/sine_est.h>
#include <gnuradio/fft/fft.h>
#include <gnuradio/thread/thread.h>
#include <volk/volk.h>
#include <string>
#include <iostream>

using namespace std;
namespace gr {
  namespace shfcc {

    class sine_est_impl : public sine_est
    {
     private:
      fft::fft_complex *d_fft;
      float d_fs;
      float d_fscale;
      int d_calc_len;
      int d_algorithm;
      int d_iterations;
      float d_known_freq;
      bool d_est_freq;
      gr_complex* d_cpx_data;
      gr_complex* d_cpx_datb;
      gr_complex* d_cpx_datc;
      float* d_flt_data;
      size_t d_alignment;
      gr::thread::mutex d_mtx;  
      void ye_est(float *freq , gr_complex *amplitude , const float *in_data  );
      void amp_est(gr_complex *amplitude , const float *in_data  );
      void snr_est(float *snr, const float *freq, const gr_complex *amplitude, const float *in_data);  

     public:
      sine_est_impl(float fs, bool est_freq, float known_freq, int calc_len, int alg, int iters, float freq_scale);
      ~sine_est_impl();
      void set_calc_len(size_t calc_len);
      void set_est_freq(bool estimate);
      void set_known_freq(float freq);

      int work(int noutput_items,
         gr_vector_const_void_star &input_items,
         gr_vector_void_star &output_items);
    };
  } // namespace shfcc
} // namespace gr
#endif /* INCLUDED_SHFCC_SINE_EST_IMPL_H */
