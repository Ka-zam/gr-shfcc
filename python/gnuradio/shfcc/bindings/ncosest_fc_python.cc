/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

#include <gnuradio/shfcc/ncosest_fc.h>

void bind_ncosest_fc(py::module& m)
{
    using ncosest_fc = gr::shfcc::ncosest_fc;

    py::class_<ncosest_fc, gr::sync_decimator, std::shared_ptr<ncosest_fc>>(
        m, "ncosest_fc", "Estimate multiple sinusoids (NLS estimator)")
        .def(py::init(&ncosest_fc::make),
             py::arg("fs"),
             py::arg("freqs"),
             py::arg("nfreqs"),
             py::arg("eps_abs"),
             py::arg("Neps"),
             py::arg("calc_len"));
}
