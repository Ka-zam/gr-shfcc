
#ifndef INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_H
#define INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_H

#include <shfcc/api.h>
#include <gnuradio/sync_block.h>

namespace gr {
  namespace shfcc {

    /*!
     * \brief <Mixer with optional phase noise impairment>
     * \ingroup shfcc
     *
     */
    class SHFCC_API phase_noise_mixer_cc : virtual public gr::sync_block
    {
     public:
      typedef boost::shared_ptr<phase_noise_mixer_cc> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of shfcc::phase_noise_mixer_cc.
       *
       * To avoid accidental use of raw pointers, shfcc::phase_noise_mixer_cc's
       * constructor is in a private implementation
       * class. shfcc::phase_noise_mixer_cc::make is the public interface for
       * creating new instances.
       */
      static sptr make(float fc, float fs, float k0, float k2, float cfo_ampl, float cfo_freq, bool impair);
      virtual void set_fc(float fc) = 0;
      virtual void set_k0(float k0) = 0;
      virtual void set_k2(float k2) = 0;
      virtual void set_cfo_ampl(float cfo_ampl) = 0;
      virtual void set_cfo_freq(float cfo_ampl) = 0;
      virtual void set_impair(bool impair) = 0;

    };

  } // namespace shfcc
/* -*- c++ -*- */
} // namespace gr

#endif /* INCLUDED_SHFCC_PHASE_NOISE_MIXER_CC_H */

