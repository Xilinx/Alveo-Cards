<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>UL3524 Ultra Low Latency Trading</h1>
    </td>
 </tr>
</table>

# Latency Measurement Test Script
The scripts in this directory are used for collecting and computing the latency values of the GTF design.

A high-level description of the scripts are given below.

| Script Name | Description |
|-------------|-------------|
| run_tests.tcl | Perform latency measurement by resetting and configuring the design, and collecting and computing latency data |
| helper.tcl | Contain helper procedures that are called in `run_test.tcl` |
| config_ila_mac.tcl | Configure the ILA by setting trigger logic to **lat_mon_rcv_event_ila** == 1'b1 |
| config_ila_raw.tcl | Configure the ILA by setting trigger logic to **lat_mon_rcv_event_ila** == 1'b1 |

**Table.** Descriptions of the latency measurement scripts.

## Test Parameters
This section provides an overview of the test parameters and instructions on how to change them. 

### Overview
The table below gives a brief description and allowable values for each parameter.

| Parameter | Description |
|---|---|
| test_mode | 0: FIFO test mode: this mode collects send and receive times of each packet in memory to be processed later on the host <br><br> 1: Continous test mode: this mode accumulates the delta between the send and receive time of each packet and calculates the min and max inside the design. |
| loopback_mode | 0: Configures the design for near-end loopback <br><br> 1: Configures the design for far-end loopback |
| num_test | Set the number of test iterations <br><br> Incase of continous test mode, num_test defaults to 1 |
| pkt_cnt | Set the number of packets to send per test <br><br> Maximum number of packets that can be sent per test in FIFO test mode is 4084 |

**Table.** Description of test parameters for the latency measurement scripts.

### Changing the Parameters
Test parameters can be set by changing the values for the following variables in `run_tests.tcl`.

```tcl
# 0: FIFO test mode
# 1: Continuos test mode
set ::test_mode 0

# 0: Near-end
# 1: Far-end
set ::loopback_mode 0

# Number of test iterations
set ::num_test 1

# Number of packets to send per test
set ::pkt_cnt 250
```
## `helper.tcl` Descriptions
Descriptions of the procedures in `helper.tcl` are given below.

| Procedure Name | Description |
|-------------|-------------|
| reset_design | Reset the entire rdesign by toggling `hb_gtwiz_reset_all_in` |
| reg_wr {address value} | Perform a JTAG-AXI write |
| reg_rd {address} | Perform a JTAG-AXI read |
| hex2dec {largeHex} | Convert a hex value to decimal |
| bringup | Assuming device has been programmed, and a master reset (hb_gtwiz_reset_all) has been applied to the board or via VIO <ul> <li> Collect the configured data rate from the GTF (ctl_rx_data_rate and ctl_tx_data_rate) </li> <li> Enable gtf_ch_rx_userrdy and gtf_ch_tx_userrdy </li> <li> Configure loopback mode </li> <li> Reset the TX PMA by toggling RXPMARESET </li> <li> Check RXUSRCLK </li> <li> Reset the RX path by toggling GTRXRESET </li> <li> Intitate bitslip if configured as 10G </li> <li> Check for RX MAC block lock and link status </li> </ul> |
| send_pkts | Initiates a batch send <ul> <li> Set the frame count </li> <li> Set up the DUT and the benchmark (setup_vnc) </li> <li> Enable the frame generator and monitor </li> <li> Poll for completion by checking if the frame generator is disabled and the latency monitor is done </li>  <li> Collect latency records (get_latency) </li> </ul> |
| setup_vnc | Configure the DUT and the benchmark with the settings for the latency measurement <ul> <li> Collect the configured data rate from the GTF (ctl_rx_data_rate and ctl_tx_data_rate) </li> <li> TX </li> <ul> <li> Enable FCS insertion by the TX core </li> <li> Enable FCS error checking </li> <li> Disable custom preamble </li> <li> Enable FCS insertion by the TX core </li> </ul> <li> RX </li> <ul> <li> Enable FCS error checking </li> <li> Disable custom preamble </li> </ul> </ul> |
| get_latency | For FIFO test mode <ul> <li> Collect individual latency records from the FIFO </li> <li> Calculate min, avg, and max </li> </ul> |
| get_latency_cont | For continous test mode <ul> <li> Collect min, max, and delta accumulator values from the latency monitor </li> <li> Calculate the average by dividing the delta accumulator value by the number of packets recorded </li> </ul> |

**Table.** Descriptions of the procedures in `helper.tcl`.
