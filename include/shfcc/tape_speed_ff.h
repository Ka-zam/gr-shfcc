/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 * 
 */


#ifndef INCLUDED_SHFCC_TAPE_SPEED_FF_H
#define INCLUDED_SHFCC_TAPE_SPEED_FF_H

#include <shfcc/api.h>
#include <gnuradio/block.h>

namespace gr {
  namespace shfcc {

    /*!
     * \brief Variable Speed Tape Transport
     * \ingroup shfcc
     *
     * \details
     * This block implements a variable speed tape transport
     */
    class SHFCC_API tape_speed_ff : virtual public gr::block
    {
     public:
      typedef boost::shared_ptr<tape_speed_ff> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of shfcc::tape_speed_ff.
       *
       * \param sample_rate_hz
       * \param std_dev_hz
       * \param max_dev_hz
       * \param cyclic_freq_hz
       * \param cyclic_amp_hz
       * \param noise_seed
       * To avoid accidental use of raw pointers, shfcc::tape_speed_ff's
       * constructor is in a private implementation
       * class. shfcc::tape_speed_ff::make is the public interface for
       * creating new instances.
       */
      static sptr make(double sample_rate_hz, 
      	               double std_dev_hz, 
      	               double max_dev_hz, 
      	               double cyclic_freq_hz, 
      	               double cyclic_amp_hz, 
      	               double noise_seed=0.0);

      virtual void set_std_dev(double _dev) = 0;
      virtual void set_max_dev(double _dev) = 0;
      virtual void set_samp_rate(double _rate) = 0;
      virtual void set_cyclic_freq(double _freq) = 0;
      virtual void set_cyclic_amp(double _amp) = 0;

      virtual double std_dev() const = 0;
      virtual double max_dev() const = 0;
      virtual double samp_rate() const = 0;
      virtual double cyclic_freq() const = 0;
      virtual double cyclic_amp() const = 0;      
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_TAPE_SPEED_FF_H */

