`timescale 1ns/100ps

module AtomicBuffer (
  input logic clk_i,
  input  logic rst_ni,
  input logic valid_i,
  input logic flush_i,
  output logic ready_o,
  
  input memPkt memPacket_i,
  input lsqPkt lsqPacket_i,
  
  // DCache interface
  output memPkt  memPacket_o,  // request to cache
  output lsqPkt  lsqPacket_o,  // request to cache
  output logic   valid_o
);

typedef struct packed {
  memPkt memPacket;
  lsqPkt lsqPacket;
} queued_op_t;

queued_op_t data_in, data_out;

assign data_in.memPacket = memPacket_i;
assign data_in.lsqPacket = lsqPacket_i;

assign memPacket_o = data_out.memPacket;
lsqPkt lsqPacketOut;
always_comb begin
  lsqPacketOut.isLoad = 1'b0;
  lsqPacketOut.isStore = 1'b0;
  lsqPacketOut.isValid = 1'b0;
  lsqPacketOut.seqNo = 32'h00000000;
  lsqPacketOut.predLoadVio = 1'b0;
  
  if (valid_o) begin
    lsqPacketOut.isLoad = data_out.memPacket_o.isLoad;
    lsqPacketOut.isStore = 1'b0;
    lsqPacketOut.isValid = 1'b0;
  end
end


fifo_v3 #(
  .DEPTH        ( 1                ),
  .dtype        ( queued_op_t         )
) i_amo_fifo (
  .clk_i        ( clk_i            ),
  .rst_ni       ( rst_ni           ),
  .flush_i      ( flush_i),
  .testmode_i   ( 1'b0             ),
  .full_o       ( valid_o), // if full then data is being asserted out
  .empty_o      ( ready_o          ),
  .usage_o      (  ), // left open
  .data_i       ( data_in      ),
  .push_i       ( valid_i          ),
  .data_o       ( data_out     ),
  .pop_i        ( 1'b0  )
);


endmodule