# SPDX-License-Identifier: GPL-3.0-or-later

########################################################################
# Setup library
########################################################################
list(APPEND shfcc_sources
    phase_noise_mixer_cc_impl.cc
    pack_bs_impl.cc
    map_ss_impl.cc
    cexp_est_impl.cc
    tape_speed_ff_impl.cc
    vaverage_ff_impl.cc
    sine_est_impl.cc
    ncosest_fc_impl.cc
)

set(shfcc_sources "${shfcc_sources}" PARENT_SCOPE)
if(NOT shfcc_sources)
    message(STATUS "No C++ sources... skipping lib/")
    return()
endif(NOT shfcc_sources)

add_library(gnuradio-shfcc SHARED ${shfcc_sources})
target_link_libraries(gnuradio-shfcc
    gnuradio::gnuradio-runtime
    gnuradio::gnuradio-blocks
    gnuradio::gnuradio-fft
    gnuradio::gnuradio-filter
    gnuradio::gnuradio-analog
    ${ARMADILLO_LIBRARIES}
)
target_include_directories(gnuradio-shfcc
    PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    PUBLIC $<INSTALL_INTERFACE:include>
)
set_target_properties(gnuradio-shfcc PROPERTIES DEFINE_SYMBOL "gnuradio_shfcc_EXPORTS")

if(APPLE)
    set_target_properties(gnuradio-shfcc PROPERTIES
        INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
    )
endif(APPLE)

########################################################################
# Install built library files
########################################################################
install(TARGETS gnuradio-shfcc
    LIBRARY DESTINATION lib${LIB_SUFFIX}
    ARCHIVE DESTINATION lib${LIB_SUFFIX}
    RUNTIME DESTINATION bin
)
