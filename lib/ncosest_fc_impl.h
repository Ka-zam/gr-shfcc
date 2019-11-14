/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 * 
 */

#ifndef INCLUDED_SHFCC_NCOSEST_FC_IMPL_H
#define INCLUDED_SHFCC_NCOSEST_FC_IMPL_H

#include <shfcc/ncosest_fc.h>
#include <volk/volk.h>
#include <iostream>
#include <armadillo>
#include <chrono>

using namespace std;
using namespace arma;
namespace gr {
  namespace shfcc {
  	class Timer
	{
	public:
	    Timer() : beg_(clock_::now()) {}
	    void reset() { beg_ = clock_::now(); }
	    double elapsed() const { 
	        return std::chrono::duration_cast<second_>
	            (clock_::now() - beg_).count(); }

	private:
	    typedef std::chrono::high_resolution_clock clock_;
	    typedef std::chrono::duration<double, std::ratio<1> > second_;
	    std::chrono::time_point<clock_> beg_;
	};

    class ncosest_fc_impl : public ncosest_fc
    {
     private:
     	float d_fs;
     	int d_nfreqs;
     	int d_calc_len;
     	int d_last_max_idx;
     	int d_neps;
     	fcolvec d_freqs;
     	fcolvec d_eps;
        cx_fmat d_B_mat;

        void init_B_mat();
        void epsidx2span(span &s, const int idx);
   		void linspace(fcolvec &v, const float min_val, const float max_val);
   		float calc_error(const float* in, const frowvec &freqs);
   		float calc_error2(const float* in, const int eps_idx);
   		float argmax_interp_p(const fcolvec &x, const fcolvec &y);
      void amp_est(cx_fcolvec &amp, const float* in, const float eps);
      void amp_est2(cx_fcolvec &amp, const float* in, const int eps_idx);
   		Timer d_tmr, d_tmr2;

     public:
      ncosest_fc_impl(float fs, vector<float> freqs, float eps_abs, int Neps, int calc_len);

      ~ncosest_fc_impl();

      int work(int noutput_items,
         gr_vector_const_void_star &input_items,
         gr_vector_void_star &output_items);
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_NCOSEST_FC_IMPL_H */

