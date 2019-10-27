/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
*/


#ifndef INCLUDED_SHFCC_CEXP_EST_H
#define INCLUDED_SHFCC_CEXP_EST_H

#include <shfcc/api.h>
#include <gnuradio/sync_decimator.h>

namespace gr {
  namespace shfcc {

    /*!
     * \brief <+description of block+>
     * \ingroup shfcc
     *
     */
    class SHFCC_API cexp_est : virtual public gr::sync_decimator
    {
     public:
      typedef boost::shared_ptr<cexp_est> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of shfcc::cexp_est.
       *
       * To avoid accidental use of raw pointers, shfcc::cexp_est's
       * constructor is in a private implementation
       * class. shfcc::cexp_est::make is the public interface for
       * creating new instances.
       */
      static sptr make(float fs = 1.f , int calc_len = 16, int algo = 1, int iter = 2, float freq_scale = 1.e-3);          
      virtual void set_calc_len(size_t calc_len) = 0;
    };

  } // namespace shfcc
} // namespace gr
#endif /* INCLUDED_SHFCC_CEXP_EST_H */