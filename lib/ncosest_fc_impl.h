/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 * 
 */

#ifndef INCLUDED_SHFCC_NCOSEST_FC_IMPL_H
#define INCLUDED_SHFCC_NCOSEST_FC_IMPL_H

#include <shfcc/ncosest_fc.h>

namespace gr {
  namespace shfcc {

    class ncosest_fc_impl : public ncosest_fc
    {
     private:
     	float d_fs;
     	int d_nfreqs;
     	int d_calc_len;

     public:
      ncosest_fc_impl(float fs, std::vector<float> freqs , int nfreqs, float eps_abs, int Neps, int calc_len);
      ~ncosest_fc_impl();

      int work(int noutput_items,
         gr_vector_const_void_star &input_items,
         gr_vector_void_star &output_items);
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_NCOSEST_FC_IMPL_H */

