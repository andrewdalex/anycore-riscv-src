`timescale 1ns/100ps

module AtomicBuffer (
  input logic clk_i,
  input  logic rst_ni,
  input logic valid_i,
  output logic ready_o,
  //ariane types already imported in namespace so reuse of anycore amos
  input ariane_pkg::amo_t amo_op_i,
  input logic [`SIZE_DATA-1:0] data_i,
  input logic [`SIZE_DATA-1:0] paddr_i,
  input logic [1:0] data_size_i, //size of request (e.g. word, half word etc.)
  
  // DCache interface
  output ariane_pkg::amo_req_t  amo_req_o,  // request to cache
  input  ariane_pkg::amo_resp_t amo_resp_i, // response from cache
  
  input logic no_mem_ops_pending_i // only execute amo if LSQ is drained
);

typedef struct packed {
  ariane_pkg::amo_t op;
  logic [riscv::PLEN-1:0] paddr;
  logic [63:0] data;
  logic [1:0] size;
} amo_op_t;

amo_op_t amo_data_in, amo_data_out;
assign amo_data_in.op = amo_op_i;
assign amo_data_in.data = data_i;
assign amo_data_in.paddr = paddr_i;
assign amo_data_in.size = data_size_i;

fifo_v3 #(
  .DEPTH        ( 1                ),
  .dtype        ( amo_op_t         )
) i_amo_fifo (
  .clk_i        ( clk_i            ),
  .rst_ni       ( rst_ni           ),
  .flush_i      ( 1'b0 ),
  .testmode_i   ( 1'b0             ),
  .full_o       ( amo_valid        ),
  .empty_o      ( ready_o          ),
  .usage_o      (  ), // left open
  .data_i       ( amo_data_in      ),
  .push_i       ( valid_i          ),
  .data_o       ( amo_data_out     ),
  .pop_i        ( amo_resp_i.ack   )
);


endmodule