/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

#include <gnuradio/shfcc/pack_bs.h>

void bind_pack_bs(py::module& m)
{
    using pack_bs = gr::shfcc::pack_bs;

    py::class_<pack_bs, gr::sync_decimator, std::shared_ptr<pack_bs>>(
        m, "pack_bs", "Pack bytes to shorts")
        .def(py::init(&pack_bs::make),
             py::arg("endianness"));
}
