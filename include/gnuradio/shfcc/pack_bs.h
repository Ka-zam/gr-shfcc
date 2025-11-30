/* -*- c++ -*- */
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_GNURADIO_SHFCC_PACK_BS_H
#define INCLUDED_GNURADIO_SHFCC_PACK_BS_H

#include <gnuradio/shfcc/api.h>
#include <gnuradio/sync_decimator.h>
#include <gnuradio/endianness.h>
#include <memory>

namespace gr {
namespace shfcc {

/*!
 * \brief Pack bytes to shorts
 * \ingroup shfcc
 */
class SHFCC_API pack_bs : virtual public gr::sync_decimator
{
public:
    typedef std::shared_ptr<pack_bs> sptr;

    static sptr make(endianness_t endianness);
};

} // namespace shfcc
} // namespace gr

#endif /* INCLUDED_GNURADIO_SHFCC_PACK_BS_H */
