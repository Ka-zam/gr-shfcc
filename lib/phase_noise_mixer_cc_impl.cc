#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "phase_noise_mixer_cc_impl.h"

namespace gr {
  namespace shfcc {

    phase_noise_mixer_cc::sptr
    phase_noise_mixer_cc::make(float fc, float fs, float k0, float k2, float k3, bool impair)
    {
      return gnuradio::get_initial_sptr
        (new phase_noise_mixer_cc_impl(fc, fs, k0, k2, k3, impair));
    }

    phase_noise_mixer_cc_impl::phase_noise_mixer_cc_impl(float fc, float fs, float k0, float k2, float k3, bool impair)
      : gr::sync_block("phase_noise_mixer_cc",
              gr::io_signature::make(1, 1, sizeof(gr_complex)),
              gr::io_signature::make(1, 1, sizeof(gr_complex)))
    {
      d_fs = fs;
      d_counter = 0;

      d_phase = lv_cmake(1.f , 0.f);

      set_impair(impair);
      set_fc(d_fc);
      set_k0(k0);
      set_k2(k2);
      set_k3(k3);

      long seed = 123456789;

      //d_k0_rng(seed);
      //d_k2_rng(seed);

    }

    phase_noise_mixer_cc_impl::~phase_noise_mixer_cc_impl()
    {
    }

    void
    phase_noise_mixer_cc_impl::set_fc(float fc)
    {
      d_fc = fc;
      d_pha_inc = exp( gr_complex(0 , d_fc*2.0f*M_PI/d_fs) );
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
    phase_noise_mixer_cc_impl::set_k3(float k3)
    {
      d_k3 = k3;
    }   

    void
    phase_noise_mixer_cc_impl::set_impair(bool impair)
    {
      d_impair = impair;
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
        
        // Noise modelling
        float* k0_pha = (float *) malloc(noutput_items*sizeof(float));
        float* k2_pha = (float *) malloc(noutput_items*sizeof(float));

        for (int i = 0; i < noutput_items; i++)
        {
          k0_pha[i] = d_k0*d_k0_rng.gasdev();
        }

        k2_pha[0] = d_k2_last_value;

        for (int i = 0; i < noutput_items - 1; i++)
        {
          k2_pha[i] = k2_pha[i-1] + d_k2*d_k2_rng.gasdev();
        }

        d_k2_last_value = k2_pha[noutput_items - 1];

        for (int i = 0; i < noutput_items; i++)
        {
          k0_pha[i] = k0_pha[i] + k2_pha[i];
        }



        for (int i = 0; i < noutput_items; i++)
        {
          out[i] = rotate(in[i]) * exp( gr_complex(0 , k0_pha[i]) );
        }

        free(k0_pha);
        free(k2_pha);

        // Generate output signal
        //std::memcpy(out , in , noutput_items*sizeof(gr_complex) );

      }
      else{
        //
        volk_32fc_s32fc_x2_rotator_32fc(out, in, d_pha_inc, &d_phase, noutput_items);        

      }

      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */

