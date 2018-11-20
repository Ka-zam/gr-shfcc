INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_SHFCC shfcc)

FIND_PATH(
    SHFCC_INCLUDE_DIRS
    NAMES shfcc/api.h
    HINTS $ENV{SHFCC_DIR}/include
        ${PC_SHFCC_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /usr/local/include
          /usr/include
)

FIND_LIBRARY(
    SHFCC_LIBRARIES
    NAMES gnuradio-shfcc
    HINTS $ENV{SHFCC_DIR}/lib
        ${PC_SHFCC_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /usr/local/lib
          /usr/local/lib64
          /usr/lib
          /usr/lib64
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(SHFCC DEFAULT_MSG SHFCC_LIBRARIES SHFCC_INCLUDE_DIRS)
MARK_AS_ADVANCED(SHFCC_LIBRARIES SHFCC_INCLUDE_DIRS)

