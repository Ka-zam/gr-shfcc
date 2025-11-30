/* -*- c++ -*- */
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_GNURADIO_SHFCC_CEXP_EST_H
#define INCLUDED_GNURADIO_SHFCC_CEXP_EST_H

#include <gnuradio/shfcc/api.h>
#include <gnuradio/sync_decimator.h>
#include <memory>

namespace gr {
namespace shfcc {

/*!
 * \brief Complex exponential parameter estimation
 * \ingroup shfcc
 */
class SHFCC_API cexp_est : virtual public gr::sync_decimator
{
public:
    typedef std::shared_ptr<cexp_est> sptr;

    static sptr make(float fs = 1.f, int calc_len = 16, int algo = 1, int iter = 2, float freq_scale = 1.e-3);
    virtual void set_calc_len(size_t calc_len) = 0;
};

} // namespace shfcc
} // namespace gr

#endif /* INCLUDED_GNURADIO_SHFCC_CEXP_EST_H */
