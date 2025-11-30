/* -*- c++ -*- */
/*
 * Copyright 2018 Magnus Lundmark.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_GNURADIO_SHFCC_VAVERAGE_FF_H
#define INCLUDED_GNURADIO_SHFCC_VAVERAGE_FF_H

#include <gnuradio/shfcc/api.h>
#include <gnuradio/sync_decimator.h>
#include <memory>

namespace gr {
namespace shfcc {

/*!
 * \brief Vector average
 * \ingroup shfcc
 * \details
 * This block averages a selectable number of vectors
 */
class SHFCC_API vaverage_ff : virtual public gr::sync_decimator
{
public:
    typedef std::shared_ptr<vaverage_ff> sptr;

    static sptr make(int m, size_t vlen);
};

} // namespace shfcc
} // namespace gr

#endif /* INCLUDED_GNURADIO_SHFCC_VAVERAGE_FF_H */
