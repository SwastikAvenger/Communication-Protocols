
//The TestBench module will simulate the APB Slave and communicate with the DUT

`timescale 1ns/1ps

module tb_master();
    reg PCLK, rst_n;
    reg PREADY;             //CONFUSION
    wire PSELx, PENABLE;
    wire [31:0] PADDR, PWDATA;
    wire PWRITE;
    
    reg transfer;
    reg [31:0] addr, wdata;
    reg write;
    
    //DUT
    master dut(
        .PCLK(PCLK),
        .rst_n(rst_n),
        .transfer(transfer),
        .addr(addr),
        .wdata(wdata),
        .write(write),
        .PREADY(PREADY),
        .PSELx(PSELx),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE)
    );
    
    //Initialize variables
    initial begin
        {PCLK, transfer, addr, wdata, write} = 0;
    end
    
    //Clock generation
    always #5 PCLK = ~PCLK;
    
    initial begin
        
        repeat(20) begin   
            rst_n = 1'b0;
            write = 1'b1;
            PREADY = 1'b0;      //SLAVE IS NOT READY
        end
        
        rst_n = 1'b1;
        @(posedge PCLK);
            transfer = 1'b1;
            addr = 32'habcd_1234;       //Random Address
            wdata = 32'hdead_dead;      //Random Data
            write = 1'b1;               //Write Operation
        
        @(posedge PCLK);
            transfer = 1'b0; 
        
        repeat(3) @(posedge PCLK);      //intentional delay, waiting for three clock cycles
        PREADY = 1'b1;   
        
        @(posedge PCLK);
            PREADY = 1'b0;
        
        #100; 
        $finish; 
    end
endmodule