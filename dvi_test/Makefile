# configuration
NEXTPNR ?= nextpnr-ice40
YOSYS ?= yosys
ICEPROG ?= iceprog
ICEPACK ?= icepack
ICETIME ?= icetime
PCF_PATH = ../utils/icebreaker.pcf
FPGA_PKG = sg48
FPGA_TYPE = up5k

# included modules
SYNTH_SOURCES += ../utils/clock_gen_25MHz.sv
SYNTH_SOURCES += ../utils/dvi_controller.sv

# `make square` makes the .bin file, then run `iceprog square.bin` to program the FPGA
square: 
	iceprog square.bin

%.json: top_%.sv $(SYNTH_SOURCES)
	$(YOSYS) -ql $(basename $@).yslog -p 'synth_ice40 -top top_$(basename $@) -json $@' top_$(basename $@).sv $(SYNTH_SOURCES)

%.asc: %.json
	$(NEXTPNR) -ql $(basename $@).nplog --${FPGA_TYPE} --package ${FPGA_PKG} --freq 12 --asc $@ --pcf $(PCF_PATH) --json $< --top top_$(basename $@)

%.rpt: %.asc
	$(ICETIME) -d ${FPGA_TYPE} -c 12 -mtr $@ $<

%.bin: %.asc
	$(ICEPACK) $< $(subst top_,,$@)

clean:
	rm -rf *.json *.asc *.rpt *.bin *yslog *.nplog

.PHONY: prog clean
