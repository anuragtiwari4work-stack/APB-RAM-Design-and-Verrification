# APB Slave Design and Testbench

## Overview

This repository contains a SystemVerilog implementation of an APB (Advanced Peripheral Bus) slave module with a comprehensive UVM-like testbench environment. The design implements a simple memory-mapped peripheral that can handle read and write operations over the APB protocol.

## Design Architecture

### APB Slave Module (`apb_s`)

The APB slave module implements a state machine-based approach to handle APB transactions:

**Key Features:**
- 16-location memory array (8-bit wide)
- Address range: 0-15
- Full APB protocol compliance
- Error detection and reporting
- State-machine based implementation

**States:**
- `IDLE`: Waiting for transaction initiation
- `WRITE`: Handling write operations
- `READ`: Handling read operations

**Error Detection:**
- Address range validation (0-15)
- Address validity checks
- Data validity checks
- Error reporting via `pslverr` signal

### Interface Specification (`abp_if`)

```systemverilog
interface abp_if ();
   logic        pclk;     // APB clock
   logic        presetn;  // APB reset (active low)
   logic [31:0] paddr;    // APB address bus
   logic        psel;     // APB select signal
   logic        penable;  // APB enable signal
   logic [7:0]  pwdata;   // APB write data
   logic        pwrite;   // APB write/read control
   logic [7:0]  prdata;   // APB read data
   logic        pready;   // APB ready signal
   logic        pslverr;  // APB slave error signal
endinterface
```

## Testbench Architecture

The testbench follows a layered verification approach with the following components:

### 1. Transaction Class
- Defines the transaction structure
- Implements constraints for address (0-15) and data (0-255)
- Provides display methods for debugging

### 2. Generator
- Creates randomized transactions
- Controls the number of test iterations
- Implements event-based synchronization

### 3. Driver
- Implements APB protocol sequences
- Handles both read and write operations
- Manages reset functionality
- Drives signals to the DUT

### 4. Monitor
- Captures transactions from the interface
- Samples data when `pready` is asserted
- Forwards captured data to scoreboard

### 5. Scoreboard
- Implements reference model functionality
- Maintains expected memory state
- Compares actual vs expected results
- Reports mismatches and errors

### 6. Environment
- Integrates all testbench components
- Manages mailbox communications
- Controls test flow (pre_test, test, post_test)

## File Structure

```
├── apb_s.sv          # APB slave design module
├── tb.sv             # Complete testbench with all classes
├── dump.vcd          # Generated waveform file
└── README.md         # This file
```

## Key Features

### Design Features
- **Protocol Compliance**: Full APB protocol implementation
- **Memory Interface**: 16 x 8-bit memory locations
- **Error Handling**: Comprehensive error detection
- **State Machine**: Clean FSM implementation for transaction handling

### Testbench Features
- **Randomized Testing**: Constrained random transaction generation
- **Self-Checking**: Automatic result verification
- **Coverage**: Tests both read and write operations
- **Error Testing**: Validates error conditions
- **Debugging**: Comprehensive transaction logging

## Usage

### Running the Simulation

```bash
# Compile and run with your SystemVerilog simulator
# For example, with Questa/ModelSim:
vlog +acc *.sv
vsim -voptargs=+acc work.tb
run -all
```

### Configuration

The testbench can be configured by modifying parameters in the initial block:

```systemverilog
initial begin
   env = new(vif);
   env.gen.count = 20;  // Number of transactions to generate
   env.run();
end
```

### Waveform Analysis

The testbench generates a VCD file (`dump.vcd`) for waveform analysis:
- View signal transitions
- Debug protocol violations
- Analyze timing relationships

## Test Scenarios

The testbench automatically tests:

1. **Write Operations**: Random data to random valid addresses
2. **Read Operations**: Verification of previously written data
3. **Error Conditions**: 
   - Out-of-range addresses (>15)
   - Invalid address conditions
   - Data validity checks
4. **Protocol Compliance**: Proper APB handshaking
5. **Reset Functionality**: Proper initialization

## Expected Output

During simulation, you'll see output similar to:

```
[DRV] : RESET DONE
[GEN] : paddr:5 pwdata:100 pwrite:1 prdata:0 pslverr:0 @ 150
[DRV] : paddr:5 pwdata:100 pwrite:1 prdata:0 pslverr:0 @ 190
[MON] : paddr:5 pwdata:100 pwrite:1 prdata:0 pslverr:0 @ 210
[SCO] : paddr:5 pwdata:100 pwrite:1 prdata:0 pslverr:0 @ 210
[SCO] : DATA STORED DATA : 100 ADDR: 5
```

## Error Reporting

The testbench provides detailed error reporting:
- Transaction-level mismatches
- Protocol violations
- Final error count summary

## Customization

### Adding New Test Scenarios
1. Modify constraints in the `transaction` class
2. Add new test sequences in the `generator`
3. Extend error checking in the `scoreboard`

### Extending the Design
1. Increase memory size by modifying the `mem` array
2. Add new APB signals as needed
3. Implement additional error conditions

## Dependencies

- SystemVerilog-compatible simulator
- Support for interfaces and classes
- Mailbox and event constructs

## Known Issues

- Address validity checks (`av_t` and `dv_t`) may need refinement
- Consider adding timing checks for APB protocol compliance
- Additional coverage metrics could be implemented

## Contributing

When contributing to this codebase:
1. Follow SystemVerilog coding standards
2. Add appropriate comments and documentation
3. Test thoroughly with multiple scenarios
4. Update this README for any architectural changes

## License

This code is provided for educational and development purposes.
