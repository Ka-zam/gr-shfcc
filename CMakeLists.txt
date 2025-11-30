# Copyright 2011-2024 Free Software Foundation, Inc.
#
# This file is part of gr-shfcc
#
# SPDX-License-Identifier: GPL-3.0-or-later

########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 3.8)
project(gr-shfcc CXX C)
enable_testing()

# Install to PyBOMBS target prefix if defined
if(DEFINED ENV{PYBOMBS_PREFIX})
    set(CMAKE_INSTALL_PREFIX $ENV{PYBOMBS_PREFIX})
    message(STATUS "PyBOMBS installed GNU Radio. Setting CMAKE_INSTALL_PREFIX to $ENV{PYBOMBS_PREFIX}")
endif()

# Select the release build type by default
if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE "Release")
   message(STATUS "Build type not specified: defaulting to release.")
endif()
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "")

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

########################################################################
# Compiler specific setup
########################################################################
if((CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
   AND NOT WIN32)
    add_compile_options(-Wall -Wno-unknown-pragmas)
    add_compile_options(-fvisibility=hidden)
endif()

########################################################################
# Find GNU Radio
########################################################################
find_package(Gnuradio "3.10" REQUIRED COMPONENTS runtime blocks fft filter analog volk)

########################################################################
# Find Armadillo
########################################################################
find_package(Armadillo "7.300" REQUIRED)
include_directories(${ARMADILLO_INCLUDE_DIRS})

########################################################################
# Setup the include and linker paths
########################################################################
include_directories(
    ${CMAKE_SOURCE_DIR}/lib
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_BINARY_DIR}/lib
    ${CMAKE_BINARY_DIR}/include
)

########################################################################
# Find gnuradio cmake modules and use them
########################################################################
# search for GNU Radio cmake modules first in the install dir
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake/Modules)
include(GrPlatform)

########################################################################
# Install directories
########################################################################
set(GR_RUNTIME_DIR      bin)
set(GR_LIBRARY_DIR      lib${LIB_SUFFIX})
set(GR_INCLUDE_DIR      include/gnuradio/shfcc)
set(GR_DATA_DIR         share)
set(GR_PKG_DATA_DIR     ${GR_DATA_DIR}/${CMAKE_PROJECT_NAME})
set(GR_DOC_DIR          ${GR_DATA_DIR}/doc)
set(GR_PKG_DOC_DIR      ${GR_DOC_DIR}/${CMAKE_PROJECT_NAME})
set(GR_CONF_DIR         etc)
set(GR_PKG_CONF_DIR     ${GR_CONF_DIR}/${CMAKE_PROJECT_NAME}/conf.d)
set(GR_LIBEXEC_DIR      libexec)
set(GR_PKG_LIBEXEC_DIR  ${GR_LIBEXEC_DIR}/${CMAKE_PROJECT_NAME})
set(GRC_BLOCKS_DIR      ${GR_PKG_DATA_DIR}/grc/blocks)

########################################################################
# Find pybind11
########################################################################
find_package(pybind11 REQUIRED)

########################################################################
# Find Python
########################################################################
find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

########################################################################
# Create uninstall target
########################################################################
configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
@ONLY)

add_custom_target(uninstall
    ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
)

########################################################################
# Add subdirectories
########################################################################
add_subdirectory(include/gnuradio/shfcc)
add_subdirectory(lib)
add_subdirectory(python/gnuradio/shfcc)
add_subdirectory(grc)

########################################################################
# Install cmake search helper for this library
########################################################################
include(CMakePackageConfigHelpers)

configure_package_config_file(
    ${CMAKE_SOURCE_DIR}/cmake/Modules/shfccConfig.cmake.in
    ${CMAKE_BINARY_DIR}/cmake/Modules/shfccConfig.cmake
    INSTALL_DESTINATION ${GR_LIBRARY_DIR}/cmake/gnuradio-shfcc
)

install(FILES
    ${CMAKE_BINARY_DIR}/cmake/Modules/shfccConfig.cmake
    DESTINATION ${GR_LIBRARY_DIR}/cmake/gnuradio-shfcc
)
