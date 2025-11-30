# SPDX-License-Identifier: GPL-3.0-or-later

install(FILES
    shfcc_phase_noise_mixer_cc.block.yml
    shfcc_pack_bs.block.yml
    shfcc_map_ss.block.yml
    shfcc_cexp_est.block.yml
    shfcc_tape_speed_ff.block.yml
    shfcc_vaverage_ff.block.yml
    shfcc_sine_est.block.yml
    shfcc_ncosest_fc.block.yml
    DESTINATION share/gnuradio/grc/blocks
)
