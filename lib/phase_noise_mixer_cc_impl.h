#ifndef INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_IMPL_H
#define INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_IMPL_H

#include <gnuradio/shfcc/phase_noise_mixer_cc.h>
#include <gnuradio/gr_complex.h>
#include <gnuradio/random.h>
#include <cmath>
#include <cstring> //memcpy
#include <volk/volk.h>

namespace gr {
  namespace shfcc {

    class phase_noise_mixer_cc_impl : public phase_noise_mixer_cc
    {
     private:
     	gr_complex d_phase;
     	gr_complex d_pha_inc;
      uint32_t d_counter;

      double d_fc;
      double d_fc_nominal;
      double d_fs;

      float d_k0;
      float d_k2;
      float d_k2_last_value;

      float d_cfo_pha_inc;
      float d_cfo_pha;
      float d_cfo_freq;
      float d_cfo_ampl;
      
      bool d_impair;

      gr::random d_k0_rng;
      gr::random d_k2_rng;

     public:
      phase_noise_mixer_cc_impl(double fc, double fs, float k0, float k2, float cfo_ampl, float cfo_freq, bool impair);
      ~phase_noise_mixer_cc_impl();
      void set_fc(double fc);
      void set_fc_nominal(double fc_nom);
      void set_k0(float k0);
      void set_k2(float k2);
      void set_cfo_ampl(float cfo_ampl);
      void set_cfo_freq(float cfo_freq);
      void set_impair(bool impair);
      gr_complex rotate(gr_complex in);

      int work(int noutput_items,
         gr_vector_const_void_star &input_items,
         gr_vector_void_star &output_items);
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_IMPL_H */

