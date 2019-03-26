#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "phase_noise_mixer_cc_impl.h"

namespace gr {
  namespace shfcc {

    phase_noise_mixer_cc::sptr
    phase_noise_mixer_cc::make(double fc, double fs, float k0, float k2, float cfo_ampl, float cfo_freq, bool impair)
    {
      return gnuradio::get_initial_sptr
        (new phase_noise_mixer_cc_impl(fc, fs, k0, k2, cfo_ampl, cfo_freq, impair));
    }

    phase_noise_mixer_cc_impl::phase_noise_mixer_cc_impl(double fc, 
      double fs, float k0, float k2, float cfo_ampl, float cfo_freq, bool impair)
      : gr::sync_block("phase_noise_mixer_cc",
              gr::io_signature::make(1, 1, sizeof(gr_complex)),
              gr::io_signature::make(1, 1, sizeof(gr_complex)))
    {
      d_fs = fs;
      d_counter = 0;

      d_phase = lv_cmake(1.f , 0.f);

      set_impair(impair);
      //set_fc(fc);
      set_fc_nominal(fc);
      set_k0(k0);
      set_k2(k2);
      
      d_k2_last_value = 0.f;
      set_min_noutput_items(2);

      d_cfo_ampl = cfo_ampl;
      d_cfo_pha = 0.f;
      d_cfo_pha_inc = 2.0*M_PI*cfo_freq/d_fs;

    }

    phase_noise_mixer_cc_impl::~phase_noise_mixer_cc_impl()
    {
    }

    void
    phase_noise_mixer_cc_impl::set_fc_nominal(double fc_nom)
    {
      d_fc_nominal = fc_nom;
      //d_pha_inc = exp( gr_complex(0 , fc_nom*2.0*M_PI/d_fs) );
      set_fc(fc_nom);
    }

    void
    phase_noise_mixer_cc_impl::set_fc(double fc)
    {
      d_fc = fc;
      d_pha_inc = exp( gr_complex(0.0 , 2.0*M_PI*(fc/d_fs) ) );
      d_pha_inc /= std::abs( d_pha_inc );
    }

    void
    phase_noise_mixer_cc_impl::set_k0(float k0)
    {
      d_k0 = k0;
    }

    void
    phase_noise_mixer_cc_impl::set_k2(float k2)
    {
      d_k2 = k2;
    }

    void
    phase_noise_mixer_cc_impl::set_cfo_freq(float cfo_freq)
    {
      d_cfo_freq = cfo_freq;
      d_cfo_pha_inc = 2.0*M_PI*cfo_freq/d_fs;
    }  

    void
    phase_noise_mixer_cc_impl::set_cfo_ampl(float cfo_ampl)
    {
      d_cfo_ampl = cfo_ampl;
    }       

    void
    phase_noise_mixer_cc_impl::set_impair(bool impair)
    {
      d_impair = impair;
      //Set frequency to nominal value
      set_fc_nominal(d_fc_nominal);
      d_k2_last_value = 0.f;
      if (d_impair){
        d_phase = gr_complex(1.,1.);
      }
    }    

    gr_complex 
    phase_noise_mixer_cc_impl::rotate(gr_complex in)
    {
      d_counter++;

        gr_complex z = in * d_phase;    // rotate in by phase
        d_phase *= d_pha_inc;      // incr our phase (complex mult == add phases)

        if((d_counter % 512) == 0)
          d_phase /= std::abs(d_phase);     // Normalize to ensure multiplication is rotation

        return z;
      }

    int
    phase_noise_mixer_cc_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      const gr_complex *in = (const gr_complex *) input_items[0];
      gr_complex *out = (gr_complex *) output_items[0];
      
      if (d_impair){

        float k2_pha = d_k2_last_value + d_k2*d_k2_rng.gasdev();  
        float k0_pha = d_k0*d_k0_rng.gasdev();
             
        for (int i = 0; i < noutput_items-1; i++)
        {
          //Calculate center frequency offset
          out[i] = rotate(in[i]) * exp( gr_complex(0 , k0_pha + k2_pha) );
          k0_pha  = d_k0*d_k0_rng.gasdev();
          k2_pha += d_k2*d_k2_rng.gasdev();
          if (d_cfo_ampl > 1.e-6){
            d_cfo_pha += d_cfo_pha_inc;
            if (d_cfo_pha > 2.0*M_PI) {d_cfo_pha -= 2.0*M_PI;}
            set_fc( d_fc_nominal + d_cfo_ampl*cos(d_cfo_pha) );
          }
        }
        out[noutput_items-1] = 
            rotate(in[noutput_items-1]) * exp( gr_complex(0.0 , k0_pha + k2_pha) );
        d_k2_last_value = k2_pha;                
      }
      else{
        volk_32fc_s32fc_x2_rotator_32fc(out, in, d_pha_inc, &d_phase, noutput_items);
      }
      return noutput_items;
    }
  } /* namespace shfcc */
} /* namespace gr */

