/* -*- c++ -*- */
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_GNURADIO_SHFCC_MAP_SS_H
#define INCLUDED_GNURADIO_SHFCC_MAP_SS_H

#include <gnuradio/shfcc/api.h>
#include <gnuradio/sync_block.h>
#include <memory>
#include <vector>

namespace gr {
namespace shfcc {

/*!
 * \brief Map short values
 * \ingroup shfcc
 */
class SHFCC_API map_ss : virtual public gr::sync_block
{
public:
    typedef std::shared_ptr<map_ss> sptr;

    static sptr make(const std::vector<int> &map);
};

} // namespace shfcc
} // namespace gr

#endif /* INCLUDED_GNURADIO_SHFCC_MAP_SS_H */
