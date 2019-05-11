/* -*- c++ -*- */
/* 
 * Copyright 2018 Magnus Lundmark.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifndef INCLUDED_SHFCC_VAVERAGE_FF_IMPL_H
#define INCLUDED_SHFCC_VAVERAGE_FF_IMPL_H

#include <shfcc/vaverage_ff.h>

namespace gr {
  namespace shfcc {

    class vaverage_ff_impl : public vaverage_ff
    {
     private:
      // Nothing to declare in this block.
      int d_alignment;
      int d_m;
      size_t d_vlen;

     public:
      vaverage_ff_impl(int m, size_t vlen);
      ~vaverage_ff_impl();

      // Where all the action really happens
      int work(int noutput_items,
         gr_vector_const_void_star &input_items,
         gr_vector_void_star &output_items);
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_VAVERAGE_FF_IMPL_H */

