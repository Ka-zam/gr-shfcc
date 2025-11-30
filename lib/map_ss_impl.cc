/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 * 
*/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "map_ss_impl.h"

namespace gr {
  namespace shfcc {

    map_ss::sptr
    map_ss::make(const std::vector<int> &map)
    {
      return std::make_shared<map_ss_impl>(map);
    }

    /*
     * The private constructor
     */
    map_ss_impl::map_ss_impl(const std::vector<int> &map)
      : gr::sync_block("map_ss",
              gr::io_signature::make(1 , 1 , sizeof(uint16_t)),
              gr::io_signature::make(1 , 1 , sizeof(uint16_t)))
    {
      set_map(map);
    }

    /*
     * Our virtual destructor.
     */
    map_ss_impl::~map_ss_impl()
    {
    }

    void
    map_ss_impl::set_map(const std::vector<int> &map)
    {
      gr::thread::scoped_lock guard(d_mutex);

      for(int i = 0; i < 0x10000; i++)
        d_map[i] = i;

      unsigned int size = std::min((size_t)0x10000, map.size());
      for(unsigned int i = 0; i < size; i++)
        d_map[i] = map[i];
    } 

    std::vector<int>
    map_ss_impl::map() const
    {
      std::vector<int> m;
      for(uint32_t  i = 0; i < 0x10000; i++)
        m[i] = d_map[i];
      return m;
    }

    int
    map_ss_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      gr::thread::scoped_lock guard(d_mutex);

      const uint16_t *in = (const uint16_t *) input_items[0];
      uint16_t *out = (uint16_t *) output_items[0];

      for(int i = 0; i < noutput_items; i++) {
        out[i] = d_map[in[i]];      
      }

      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */

