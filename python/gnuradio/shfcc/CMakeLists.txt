# SPDX-License-Identifier: GPL-3.0-or-later

########################################################################
# Python bindings
########################################################################
list(APPEND shfcc_python_files
    bindings/python_bindings.cc
    bindings/phase_noise_mixer_cc_python.cc
    bindings/pack_bs_python.cc
    bindings/map_ss_python.cc
    bindings/cexp_est_python.cc
    bindings/tape_speed_ff_python.cc
    bindings/vaverage_ff_python.cc
    bindings/sine_est_python.cc
    bindings/ncosest_fc_python.cc
)

pybind11_add_module(shfcc_python ${shfcc_python_files})
target_link_libraries(shfcc_python PUBLIC gnuradio-shfcc)
target_include_directories(shfcc_python
    PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    PUBLIC $<INSTALL_INTERFACE:include>
)

########################################################################
# Install Python module
########################################################################
execute_process(
    COMMAND "${Python3_EXECUTABLE}" -c
    "import site; print(site.getsitepackages()[0])"
    OUTPUT_VARIABLE PYTHON_SITE_PACKAGES
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get just the relative path from site-packages
string(REGEX REPLACE "^.*/site-packages" "lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages" GR_PYTHON_DIR "${PYTHON_SITE_PACKAGES}")

install(TARGETS shfcc_python
    LIBRARY DESTINATION ${GR_PYTHON_DIR}/gnuradio/shfcc
    COMPONENT pythonapi
)

########################################################################
# Install Python files
########################################################################
install(FILES
    __init__.py
    DESTINATION ${GR_PYTHON_DIR}/gnuradio/shfcc
    COMPONENT pythonapi
)

########################################################################
# Install extra Python files (utilities)
########################################################################
install(FILES
    ${CMAKE_SOURCE_DIR}/python/spiralqam.py
    ${CMAKE_SOURCE_DIR}/python/phasenoise.py
    ${CMAKE_SOURCE_DIR}/python/dropout.py
    ${CMAKE_SOURCE_DIR}/python/allan.py
    DESTINATION ${GR_PYTHON_DIR}/gnuradio/shfcc
    COMPONENT pythonapi
)
