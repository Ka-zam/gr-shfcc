/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 * 
 */


#ifndef INCLUDED_SHFCC_NCOSEST_FC_H
#define INCLUDED_SHFCC_NCOSEST_FC_H

#include <shfcc/api.h>
#include <gnuradio/sync_decimator.h>

namespace gr {
  namespace shfcc {

    /*!
     * \brief <+description of block+>
     * \ingroup shfcc
     *
     */
    class SHFCC_API ncosest_fc : virtual public gr::sync_decimator
    {
     public:
      typedef boost::shared_ptr<ncosest_fc> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of shfcc::ncosest_fc.
       *
       * To avoid accidental use of raw pointers, shfcc::ncosest_fc's
       * constructor is in a private implementation
       * class. shfcc::ncosest_fc::make is the public interface for
       * creating new instances.
       */
      static sptr make(float fs, std::vector<float> freqs , int nfreqs, float eps_abs, int Neps, int calc_len);
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_NCOSEST_FC_H */

