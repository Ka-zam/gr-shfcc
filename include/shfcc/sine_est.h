/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                             Preamble
 * 
 *   The GNU General Public License is a free, copyleft license for
 * software and other kinds of works.
 * 
 *   The licenses for most software and other practical works are designed
 * to take away your freedom to share and change the works.  By contrast,
 * the GNU General Public License is intended to guarantee your freedom to
 * share and change all versions of a program--to make sure it remains free
 * software for all its users.  We, the Free Software Foundation, use the
 * GNU General Public License for most of our software; it applies also to
 *                        Version 3, 29 June 2007
 */


#ifndef INCLUDED_SHFCC_SINE_EST_H
#define INCLUDED_SHFCC_SINE_EST_H

#include <shfcc/api.h>
#include <gnuradio/sync_decimator.h>

namespace gr {
  namespace shfcc {

    /*!
     * \brief Estimate parameters from sinusoidal signal in AFGN channel
     * \ingroup shfcc
     *
     */
    class SHFCC_API sine_est : virtual public gr::sync_decimator
    {
     public:
      typedef boost::shared_ptr<sine_est> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of shfcc::sine_est.
       *
       * To avoid accidental use of raw pointers, shfcc::sine_est's
       * constructor is in a private implementation
       * class. shfcc::sine_est::make is the public interface for
       * creating new instances.
       */
      static sptr make(float fs, int calc_len, int alg, int iters, float freq_scale);
      virtual void set_calc_len(size_t calc_len) = 0;
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_SINE_EST_H */

