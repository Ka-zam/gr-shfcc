/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

#include <gnuradio/shfcc/map_ss.h>

void bind_map_ss(py::module& m)
{
    using map_ss = gr::shfcc::map_ss;

    py::class_<map_ss, gr::sync_block, std::shared_ptr<map_ss>>(
        m, "map_ss", "Map short values")
        .def(py::init(&map_ss::make),
             py::arg("map"));
}
