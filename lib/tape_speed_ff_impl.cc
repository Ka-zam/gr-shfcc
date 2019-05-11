/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "tape_speed_ff_impl.h"

namespace gr {
  namespace shfcc {

    tape_speed_ff::sptr
    tape_speed_ff::make(double sample_rate_hz, 
    	                double std_dev_hz, 
    	                double max_dev_hz, 
    	                double cyclic_freq_hz, 
    	                double cyclic_amp_hz, 
    	                double noise_seed)
    {
      return gnuradio::get_initial_sptr
        (new tape_speed_ff_impl(sample_rate_hz, std_dev_hz, max_dev_hz, cyclic_freq_hz, cyclic_amp_hz, noise_seed));
    }

    /*
     * The private constructor
     */
    tape_speed_ff_impl::tape_speed_ff_impl(double sample_rate_hz, 
    										double std_dev_hz, 
    										double max_dev_hz, 
    										double cyclic_freq_hz, 
    										double cyclic_amp_hz, 
    										double noise_seed)
      : gr::block("tape_speed_ff",
      	  	gr::io_signature::make(1, 1, sizeof(float)),
        	gr::io_signature::make(1, 1, sizeof(float))),
      		d_mu (0.0), 
      		d_mu_inc (1.0), 
      		d_sro(0.0), 
      		d_samp_rate(sample_rate_hz),
    		d_max_dev_hz(max_dev_hz), 
    		d_std_dev_hz(std_dev_hz),
			d_interp(new gr::filter::mmse_fir_interpolator_ff()),
    		d_noise(gr::analog::fastnoise_source_f::make(analog::GR_GAUSSIAN, std_dev_hz, noise_seed)),
    		d_noise_seed(noise_seed)
    {
      set_relative_rate(1.0);
    }

    /*
     * Our virtual destructor.
     */
    tape_speed_ff_impl::~tape_speed_ff_impl()
    {
    }

    void
    tape_speed_ff_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      unsigned int ninputs = ninput_items_required.size();
      for(int i=0; i < ninputs; i++) {
		ninput_items_required[i] =
	  		(int)ceil((noutput_items * (d_mu_inc + d_max_dev_hz/d_samp_rate)) + d_interp->ntaps());
      }    	
    }

    int
    tape_speed_ff_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      const float *in = (const float *) input_items[0];
      float *out = (float *) output_items[0];

      int ii = 0; // input index
      int oo = 0; // output index

      while(oo < noutput_items) {

    // perform sample rate offset update
    d_sro += d_noise->sample_unbiased();
    d_sro = std::min(d_sro, d_max_dev_hz);
    d_sro = std::max(d_sro, -d_max_dev_hz);
    d_mu_inc = 1.0 + d_sro/d_samp_rate;

	out[oo++] = d_interp->interpolate(&in[ii], d_mu);

	double s = d_mu + d_mu_inc;
	double f = floor(s);
	int incr = (int)f;
	d_mu = s - f;
	ii += incr;
      }

      consume_each(ii);

      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */

