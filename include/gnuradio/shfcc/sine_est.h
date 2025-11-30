/* -*- c++ -*- */
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_GNURADIO_SHFCC_SINE_EST_H
#define INCLUDED_GNURADIO_SHFCC_SINE_EST_H

#include <gnuradio/shfcc/api.h>
#include <gnuradio/sync_decimator.h>
#include <memory>

namespace gr {
namespace shfcc {

/*!
 * \brief Estimate parameters from sinusoidal signal in AWGN channel
 * \ingroup shfcc
 */
class SHFCC_API sine_est : virtual public gr::sync_decimator
{
public:
    typedef std::shared_ptr<sine_est> sptr;

    static sptr make(float fs, int calc_len, int alg, int iters, float freq_scale);
    virtual void set_calc_len(size_t calc_len) = 0;
};

} // namespace shfcc
} // namespace gr

#endif /* INCLUDED_GNURADIO_SHFCC_SINE_EST_H */
