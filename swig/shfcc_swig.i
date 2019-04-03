/* -*- c++ -*- */

#define SHFCC_API

%include "gnuradio.i"			// the common stuff

//load generated python docstrings
%include "shfcc_swig_doc.i"

%{
#include "shfcc/phase_noise_mixer_cc.h"
#include "shfcc/pack_bs.h"
#include "shfcc/map_ss.h"
#include "shfcc/cexp_est.h"
%}


%include "shfcc/phase_noise_mixer_cc.h"
GR_SWIG_BLOCK_MAGIC2(shfcc, phase_noise_mixer_cc);
%include "shfcc/pack_bs.h"
GR_SWIG_BLOCK_MAGIC2(shfcc, pack_bs);
%include "shfcc/map_ss.h"
GR_SWIG_BLOCK_MAGIC2(shfcc, map_ss);
%include "shfcc/cexp_est.h"
GR_SWIG_BLOCK_MAGIC2(shfcc, cexp_est);
