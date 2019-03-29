
#ifndef INCLUDED_SHFCC_MAP_SS_H
#define INCLUDED_SHFCC_MAP_SS_H

#include <shfcc/api.h>
#include <gnuradio/sync_block.h>

namespace gr {
  namespace shfcc {

    /*!
     * \brief <+description of block+>
     * \ingroup shfcc
     *
     */
    class SHFCC_API map_ss : virtual public gr::sync_block
    {
     public:
      typedef boost::shared_ptr<map_ss> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of shfcc::map_ss.
       *
       * To avoid accidental use of raw pointers, shfcc::map_ss's
       * constructor is in a private implementation
       * class. shfcc::map_ss::make is the public interface for
       * creating new instances.
       */
      static sptr make(const std::vector<int> &map);
    };

  } // namespace shfcc
} // namespace gr

#endif /* INCLUDED_SHFCC_MAP_SS_H */

