#ifndef INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_IMPL_H
#define INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_IMPL_H

#include <shfcc/phase_noise_mixer_cc.h>
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
     	float d_fc;
      float d_fs;
      float d_k0;
      float d_k2;
      float d_k3;
      bool d_impair;
      uint32_t d_counter;

      float d_k2_last_value;
      gr::random d_k0_rng;
      gr::random d_k2_rng;
     	
     public:
      phase_noise_mixer_cc_impl(float fc, float fs, float k0, float k2, float k3, bool impair);
      ~phase_noise_mixer_cc_impl();
      void set_fc(float fc);
      void set_k0(float k0);
      void set_k2(float k2);
      void set_k3(float k3);
      void set_impair(bool impair);

      int work(int noutput_items,
         gr_vector_const_void_star &input_items,
         gr_vector_void_star &output_items);
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_IMPL_H */

