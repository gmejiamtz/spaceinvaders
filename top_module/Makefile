# CSE x25 player Module make file
SYNTH_SOURCES +=  ../player/player.sv
SYNTH_SOURCES += ../provided_modules/dff.sv
SYNTH_SOURCES += ../provided_modules/inv.sv
SYNTH_SOURCES += ../provided_modules/counter.sv
SYNTH_SOURCES += ../provided_modules/sync_reset.sv
SYNTH_SOURCES += ../provided_modules/synchronizer.sv
NONSYNTH_SOURCES += ../utils/nonsynth_clock_gen.sv
NONSYNTH_SOURCES += ../utils/nonsynth_reset_gen.sv
SYNTH_SOURCES += ../utils/clock_gen_25MHz.sv
SYNTH_SOURCES += ../utils/dvi_controller.sv
-include ../fpga.mk
-include ../simulation.mk
