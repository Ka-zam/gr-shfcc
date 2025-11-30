/* -*- c++ -*- */
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_GNURADIO_SHFCC_TAPE_SPEED_FF_H
#define INCLUDED_GNURADIO_SHFCC_TAPE_SPEED_FF_H

#include <gnuradio/shfcc/api.h>
#include <gnuradio/block.h>
#include <memory>

namespace gr {
namespace shfcc {

/*!
 * \brief Variable Speed Tape Transport
 * \ingroup shfcc
 *
 * \details
 * This block implements a variable speed tape transport (wow/flutter)
 */
class SHFCC_API tape_speed_ff : virtual public gr::block
{
public:
    typedef std::shared_ptr<tape_speed_ff> sptr;

    static sptr make(double sample_rate_hz,
                     double std_dev_hz,
                     double max_dev_hz,
                     double cyclic_freq_hz,
                     double cyclic_amp_hz,
                     double noise_seed = 0.0);

    virtual void set_std_dev(double _dev) = 0;
    virtual void set_max_dev(double _dev) = 0;
    virtual void set_samp_rate(double _rate) = 0;
    virtual void set_cyclic_freq(double _freq) = 0;
    virtual void set_cyclic_amp(double _amp) = 0;

    virtual double std_dev() const = 0;
    virtual double max_dev() const = 0;
    virtual double samp_rate() const = 0;
    virtual double cyclic_freq() const = 0;
    virtual double cyclic_amp() const = 0;
};

} // namespace shfcc
} // namespace gr

#endif /* INCLUDED_GNURADIO_SHFCC_TAPE_SPEED_FF_H */
