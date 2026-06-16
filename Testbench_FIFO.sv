// Code your testbench here
// or browse Examples
module testbench;
  reg clk, rst, cs, wr_en, rd_en;
  reg [7:0] Data_in;
  wire [7:0] Data_out;
  wire full, empty, overflow, underflow;
  
  parameter FIFO_DEPTH = 16, FIFO_WIDTH = 8;
  
  
  FIFO #(.FIFO_DEPTH(FIFO_DEPTH), .FIFO_WIDTH(FIFO_WIDTH)) dut(Data_in, clk, rst, cs, wr_en, rd_en, Data_out, full, empty, overflow, underflow);
  
  always #5 clk = ~clk;
  
  // Assertions
  property asynchronous_reset;
    @(negedge rst)
      1'b0 |=> (dut.wr_ptr == 0 &&
      dut.rd_ptr == 0 &&
      dut.counter == 0);
  endproperty
  
  property counter_max;
    @(posedge clk)
    dut.counter <= FIFO_DEPTH;
  endproperty
  
  property full_flag;
    @(posedge clk)
    (dut.counter == FIFO_DEPTH) |-> full;
  endproperty
  
  property empty_flag;
    @(posedge clk)
    (dut.counter == 0) |-> empty;
  endproperty
  
  property no_conflict;
    @(posedge clk)
    !(full && empty);
  endproperty
  
  property overflow_test;
    @(posedge clk)
    overflow |-> full;
  endproperty
  
  property underflow_test;
    @(posedge clk)
    underflow |-> empty;
  endproperty
  
  property wr_ptr_range;
    @(posedge clk)
    dut.wr_ptr < FIFO_DEPTH;
  endproperty
  
  property rd_ptr_range;
    @(posedge clk)
    dut.rd_ptr < FIFO_DEPTH;
  endproperty
  
  property no_write;
    @(posedge clk)
    (wr_en && full) |=> $stable(dut.wr_ptr);
  endproperty
  
  property no_read;
    @(posedge clk)
    (rd_en && empty) |=> $stable(dut.rd_ptr);
  endproperty
    
  
  assert property(asynchronous_reset);
  assert property(counter_max);
  assert property(full_flag);
  assert property(empty_flag);
  assert property(no_conflict);
  assert property(overflow_test);
  assert property(underflow_test);
  assert property(wr_ptr_range);
  assert property(rd_ptr_range);
  assert property(no_write);
  assert property(no_read);    
    
  // Cover group
  covergroup fifo_cg @(posedge clk);
    full_cp: coverpoint full;
    empty_cp: coverpoint empty;
    wr_cp: coverpoint wr_en;
    rd_cp: coverpoint rd_en;
    overflow_cp: coverpoint overflow;
    underflow_cp: coverpoint underflow;
    
    cross wr_cp, full;
    cross rd_cp, empty;
    cross wr_cp, rd_cp;
    cross full_cp, overflow_cp;
    cross empty_cp, underflow_cp;
    
  endgroup
  fifo_cg cg;
  
  cover property(
    @(posedge clk)
    full
  );
  cover property(
    @(posedge clk)
    empty
  );
   cover property(
     @(posedge clk)
     overflow
   );
   cover property(
     @(posedge clk)
     underflow
   );
     
   
   // Score Board
   byte expected_q[$];
   always @(posedge clk) begin
     if(cs && wr_en && !full)
       expected_q.push_back(Data_in);
   end
   
   always @(posedge clk) begin
     byte expected_data;
     if(cs && rd_en && !empty) begin
       expected_data = expected_q.pop_front();
       
       #1;
       if(expected_data != Data_out)
         $error("Mismatch Expected = %0d | ActuaData = %d", expected_data, Data_out);
       else
         $display("Pass Expected = %d | ActuaData = %d", expected_data, Data_out);
     end
   end
         
    
  // Write task
  task write_data (input logic[7:0] d_in);
    @(posedge clk);
    wr_en <= 1;
    Data_in <= d_in;
    
    @(posedge clk);
    wr_en <= 0;
  endtask
  
    //Read task
  task read_data;
    @(posedge clk);
    rd_en = 1;
    @(posedge clk);
    rd_en = 0;
  endtask
  
    
  initial begin
    clk = 0; rst = 0; wr_en = 0; rd_en = 0; cs = 0;
    cg = new();
    #15 rst = 1; cs = 1;
    
    // Providing input data and reading data after once write finish
    #10 write_data(77);
    #10 write_data(45);
    #10 write_data(99);
    #10 read_data();
    #10 read_data();
    #10 read_data();
    
    
    // Writing data until it overflows
    for(int i = 0; i< FIFO_DEPTH; i++) begin
      wr_en = 1;
      Data_in <= $urandom_range(0,225);
      #10;
    end
    #10 write_data(87);
    
    //Reading data until it underflows
    for(int i = 0; i < FIFO_DEPTH; i++) begin
      rd_en = 1;
      #10;
    end
    #10 read_data();
    
    //Making CS = 0, and try to write and read data
    #10 cs = 0; write_data(34);
    #10 read_data();
    
    // Gave reset in middle of operations
    #10 cs = 1; rst = 0; 
    #30 rst = 1; write_data(74);
    #10 rd_en = 1; 
    
    // trying to write and read in single operation
    #10 wr_en = 1; Data_in = 65; rd_en = 1;
    
    //finish
    #10 $finish(); 
  end
  
  initial $monitor("clk = %b | rst = %b | cs  = %b | wr_en = %b | rd_en = %b | Data_in = %d | Data_out = %d, overflow = %b | underflow = %b", clk, rst, cs, wr_en, rd_en, Data_in, Data_out, overflow, underflow);
  
endmodule

  
  