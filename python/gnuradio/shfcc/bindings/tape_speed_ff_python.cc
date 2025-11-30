/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

#include <gnuradio/shfcc/tape_speed_ff.h>

void bind_tape_speed_ff(py::module& m)
{
    using tape_speed_ff = gr::shfcc::tape_speed_ff;

    py::class_<tape_speed_ff, gr::block, std::shared_ptr<tape_speed_ff>>(
        m, "tape_speed_ff", "Variable Speed Tape Transport (wow/flutter)")
        .def(py::init(&tape_speed_ff::make),
             py::arg("sample_rate_hz"),
             py::arg("std_dev_hz"),
             py::arg("max_dev_hz"),
             py::arg("cyclic_freq_hz"),
             py::arg("cyclic_amp_hz"),
             py::arg("noise_seed") = 0.0)
        .def("set_std_dev", &tape_speed_ff::set_std_dev)
        .def("set_max_dev", &tape_speed_ff::set_max_dev)
        .def("set_samp_rate", &tape_speed_ff::set_samp_rate)
        .def("set_cyclic_freq", &tape_speed_ff::set_cyclic_freq)
        .def("set_cyclic_amp", &tape_speed_ff::set_cyclic_amp)
        .def("std_dev", &tape_speed_ff::std_dev)
        .def("max_dev", &tape_speed_ff::max_dev)
        .def("samp_rate", &tape_speed_ff::samp_rate)
        .def("cyclic_freq", &tape_speed_ff::cyclic_freq)
        .def("cyclic_amp", &tape_speed_ff::cyclic_amp);
}
