#make         # Lint + build + run simulation
#make lint    # Only run Verilator for lint/elaboration
#make view    # Open waveform in GTKWave
#make clean   # Clean all build files

# Tools
VERILATOR = verilator
IVERILOG  = iverilog
VVP       = vvp
GTKWAVE   = gtkwave

# Directories
SRC_DIR = src
TB_DIR  = tb
BUILD_DIR = build

# Files
RTL_FILELIST = $(shell cat $(SRC_DIR)/rtl.f)
TB = $(TB_DIR)/top_tb.sv
OUT = $(BUILD_DIR)/sim.out
VCD = $(BUILD_DIR)/dump.vcd

# Default target
all: lint $(OUT)
	@echo "▶ Running simulation..."
	$(VVP) $(OUT)

# Verilator Lint: Allow warnings, stop on errors
lint:
	@echo "🔍 Running Verilator lint..."
	@mkdir -p $(BUILD_DIR)
	@$(VERILATOR) --lint-only -Wall -sv $(RTL_FILELIST) > $(BUILD_DIR)/verilator.log 2>&1 || true
	@! grep "%Error" $(BUILD_DIR)/verilator.log || (cat $(BUILD_DIR)/verilator.log && echo "\n✖ Verilator found errors. Aborting." && exit 1)
	@echo "✔ Verilator lint passed (or had only warnings)."

# Icarus simulation build
$(OUT): $(RTL_FILELIST) $(TB)
	@mkdir -p $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $(OUT) -s top_tb -c $(SRC_DIR)/rtl.f $(TB)

# View waveform
view:
	$(GTKWAVE) $(VCD) &

# Cleanup
clean:
	rm -rf $(BUILD_DIR) dump.vcd top.vcd

.PHONY: all lint clean view

