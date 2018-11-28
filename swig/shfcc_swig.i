/* -*- c++ -*- */

#define SHFCC_API

%include "gnuradio.i"			// the common stuff

//load generated python docstrings
%include "shfcc_swig_doc.i"

%{
#include "shfcc/phase_noise_mixer_cc.h"
%}


%include "shfcc/phase_noise_mixer_cc.h"
GR_SWIG_BLOCK_MAGIC2(shfcc, phase_noise_mixer_cc);
