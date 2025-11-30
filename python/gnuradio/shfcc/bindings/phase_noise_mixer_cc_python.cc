/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

#include <gnuradio/shfcc/phase_noise_mixer_cc.h>

void bind_phase_noise_mixer_cc(py::module& m)
{
    using phase_noise_mixer_cc = gr::shfcc::phase_noise_mixer_cc;

    py::class_<phase_noise_mixer_cc, gr::sync_block, std::shared_ptr<phase_noise_mixer_cc>>(
        m, "phase_noise_mixer_cc", "Mixer with optional phase noise impairment")
        .def(py::init(&phase_noise_mixer_cc::make),
             py::arg("fc"),
             py::arg("fs"),
             py::arg("k0"),
             py::arg("k2"),
             py::arg("cfo_ampl"),
             py::arg("cfo_freq"),
             py::arg("impair"))
        .def("set_fc", &phase_noise_mixer_cc::set_fc)
        .def("set_fc_nominal", &phase_noise_mixer_cc::set_fc_nominal)
        .def("set_k0", &phase_noise_mixer_cc::set_k0)
        .def("set_k2", &phase_noise_mixer_cc::set_k2)
        .def("set_cfo_ampl", &phase_noise_mixer_cc::set_cfo_ampl)
        .def("set_cfo_freq", &phase_noise_mixer_cc::set_cfo_freq)
        .def("set_impair", &phase_noise_mixer_cc::set_impair);
}
