/* -*- c++ -*- */
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_GNURADIO_SHFCC_NCOSEST_FC_H
#define INCLUDED_GNURADIO_SHFCC_NCOSEST_FC_H

#include <gnuradio/shfcc/api.h>
#include <gnuradio/sync_decimator.h>
#include <memory>
#include <vector>

namespace gr {
namespace shfcc {

/*!
 * \brief Estimate multiple sinusoids (NLS estimator)
 * \ingroup shfcc
 */
class SHFCC_API ncosest_fc : virtual public gr::sync_decimator
{
public:
    typedef std::shared_ptr<ncosest_fc> sptr;

    static sptr make(float fs, std::vector<float> freqs, int nfreqs, float eps_abs, int Neps, int calc_len);
};

} // namespace shfcc
} // namespace gr

#endif /* INCLUDED_GNURADIO_SHFCC_NCOSEST_FC_H */
