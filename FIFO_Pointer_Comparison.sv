// Code your design here

module FIFO #(parameter FIFO_DEPTH = 16, FIFO_WIDTH = 8) (input wire [FIFO_WIDTH - 1:0] Data_in, input wire clk, rst, cs, wr_en, rd_en, output reg [FIFO_WIDTH-1:0] Data_out, output logic full, empty, overflow, underflow);
  
  localparam PTR_WIDTH = $clog2(FIFO_DEPTH);
  
  logic [PTR_WIDTH : 0] wr_ptr;
  logic [PTR_WIDTH : 0] rd_ptr;
  
  logic [FIFO_WIDTH - 1:0] mem [FIFO_DEPTH - 1: 0];
  
  assign full = (wr_ptr[4] != rd_ptr[4] && wr_ptr[3:0] == rd_ptr[3:0]);
  assign empty = (wr_ptr == rd_ptr);
  
  // Write logic
  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      wr_ptr <= 0;
    end
    else if(cs && wr_en && !full) begin
      mem[wr_ptr] <= Data_in;
      wr_ptr <= wr_ptr + 1;
    end 
  end
  
  // Read logic
  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      rd_ptr <= 0;
      Data_out <= 0;
    end
    else if(cs && rd_en && !empty) begin
      Data_out <= mem[rd_ptr];
      rd_ptr <= rd_ptr + 1;
    end
  end
  
  // Overlfow nad underflow logic
  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      overflow <= 0;
      underflow <= 0;
    end
    else begin
      overflow <= wr_en && full;
      underflow <= rd_en && empty;
    end
    
  end
  
endmodule