.PHONY: all
all: fifo_spec.rkt fifo_impl.rkt

.PHONY: clean
clean:
	rm -rf *.smt2 fifo_spec.rkt fifo_impl.rkt

%.smt2: %.v
	yosys \
		-p 'read_verilog -defer $^' \
		-p 'prep -flatten -top $(patsubst %.smt2,%,$@) -nordff' \
		-p 'write_smt2 -stdt $@'

%.rkt: %.smt2
	echo '#lang yosys' > $@
	cat $< >> $@
