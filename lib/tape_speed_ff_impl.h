/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 */

#ifndef INCLUDED_SHFCC_TAPE_SPEED_FF_IMPL_H
#define INCLUDED_SHFCC_TAPE_SPEED_FF_IMPL_H

#include <gnuradio/filter/mmse_fir_interpolator_ff.h>
#include <gnuradio/analog/fastnoise_source.h>
#include <gnuradio/shfcc/tape_speed_ff.h>

namespace gr {
  namespace shfcc {

    class tape_speed_ff_impl : public tape_speed_ff
    {
     private:
      float d_mu;
      float d_mu_inc;
      float d_sro;
      float d_samp_rate;
      float d_max_dev_hz;
      float d_std_dev_hz;
      float d_cyclic_freq_hz;
      float d_cyclic_amp_hz;
      gr::filter::mmse_fir_interpolator_ff *d_interp;
      gr::analog::fastnoise_source_f::sptr d_noise;
      double d_noise_seed;     	

     public:
      tape_speed_ff_impl(double sample_rate_hz, 
      	                 double std_dev_hz, 
      	                 double max_dev_hz, 
      	                 double cyclic_freq_hz, 
      	                 double cyclic_amp_hz, 
      	                 double noise_seed=0.0);
      ~tape_speed_ff_impl();

      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);

      float mu() const;
      float interp_ratio() const;
      void set_mu(float mu);
      void set_interp_ratio(float interp_ratio);

      void set_std_dev(double _dev){ d_std_dev_hz = _dev; d_noise = gr::analog::fastnoise_source_f::make(analog::GR_GAUSSIAN, _dev, d_noise_seed); }
      void set_max_dev(double _dev){ d_max_dev_hz = _dev; }
      void set_samp_rate(double _rate){ d_samp_rate = _rate; }
      void set_cyclic_freq(double _frq){ d_cyclic_freq_hz = _frq; }
      void set_cyclic_amp(double _amp){ d_cyclic_amp_hz = _amp; }

      double std_dev() const { return d_std_dev_hz; }
      double max_dev() const { return d_max_dev_hz; }
      double samp_rate() const { return d_samp_rate; }      
      double cyclic_freq() const { return d_cyclic_freq_hz; }
      double cyclic_amp() const { return d_cyclic_amp_hz; }      
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_TAPE_SPEED_FF_IMPL_H */

