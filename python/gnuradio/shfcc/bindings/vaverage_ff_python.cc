/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

#include <gnuradio/shfcc/vaverage_ff.h>

void bind_vaverage_ff(py::module& m)
{
    using vaverage_ff = gr::shfcc::vaverage_ff;

    py::class_<vaverage_ff, gr::sync_decimator, std::shared_ptr<vaverage_ff>>(
        m, "vaverage_ff", "Vector average")
        .def(py::init(&vaverage_ff::make),
             py::arg("m"),
             py::arg("vlen"));
}
