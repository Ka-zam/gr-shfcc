/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

#include <gnuradio/shfcc/cexp_est.h>

void bind_cexp_est(py::module& m)
{
    using cexp_est = gr::shfcc::cexp_est;

    py::class_<cexp_est, gr::sync_decimator, std::shared_ptr<cexp_est>>(
        m, "cexp_est", "Complex exponential parameter estimation")
        .def(py::init(&cexp_est::make),
             py::arg("fs") = 1.f,
             py::arg("calc_len") = 16,
             py::arg("algo") = 1,
             py::arg("iter") = 2,
             py::arg("freq_scale") = 1.e-3f)
        .def("set_calc_len", &cexp_est::set_calc_len);
}
