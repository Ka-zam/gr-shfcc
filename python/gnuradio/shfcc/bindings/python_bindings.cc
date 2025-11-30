/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <pybind11/complex.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

void bind_phase_noise_mixer_cc(py::module& m);
void bind_pack_bs(py::module& m);
void bind_map_ss(py::module& m);
void bind_cexp_est(py::module& m);
void bind_tape_speed_ff(py::module& m);
void bind_vaverage_ff(py::module& m);
void bind_sine_est(py::module& m);
void bind_ncosest_fc(py::module& m);

PYBIND11_MODULE(shfcc_python, m)
{
    m.doc() = "GNU Radio shfcc module";

    bind_phase_noise_mixer_cc(m);
    bind_pack_bs(m);
    bind_map_ss(m);
    bind_cexp_est(m);
    bind_tape_speed_ff(m);
    bind_vaverage_ff(m);
    bind_sine_est(m);
    bind_ncosest_fc(m);
}
