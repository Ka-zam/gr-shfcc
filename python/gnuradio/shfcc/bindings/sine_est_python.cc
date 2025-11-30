/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

#include <gnuradio/shfcc/sine_est.h>

void bind_sine_est(py::module& m)
{
    using sine_est = gr::shfcc::sine_est;

    py::class_<sine_est, gr::sync_decimator, std::shared_ptr<sine_est>>(
        m, "sine_est", "Estimate parameters from sinusoidal signal in AWGN channel")
        .def(py::init(&sine_est::make),
             py::arg("fs"),
             py::arg("calc_len"),
             py::arg("alg"),
             py::arg("iters"),
             py::arg("freq_scale"))
        .def("set_calc_len", &sine_est::set_calc_len);
}
