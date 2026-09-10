
// APB MASTER LOGIC

`timescale 1ns / 1ps

module master(
    //From high speed processor to APB Master
        input wire PCLK,            //system clock
        input wire rst_n,           //reset
        input wire transfer,     //State transition signal
        input wire [31:0] addr,     //Address Space
        input wire [31:0] wdata,    //driven by TB
        input wire write,           //driven by TB
        
        input wire PREADY,          //From APB Slave to APB Master
        output reg PSELx,           //From APB Master to APB Slave
        output reg PENABLE,         
        output reg [31:0] PADDR,    //From APB Master to APB Slave, to select the Slave Address
        output reg [31:0] PWDATA,   //From APB Master to APB Slave, carrying the data    
        output reg PWRITE           //Read operation/write operation
    );
    
    parameter IDLE = 2'b00;     //IDLE Phase
    parameter SETUP = 2'b01;    //SETUP Phase
    parameter ACCESS = 2'b10;   //ACCESS Phase
    
    reg [1:0] current_state, next_state;
    
    //PRESENT STATE LOGIC
    always@(posedge PCLK or negedge rst_n)begin
        if(!rst_n)
            current_state <= IDLE;
        else                                                //The PRESENT STATE LOGIC is almost UNIVERSAL for all FSMs.
            current_state <= next_state;
    end
    
    //NEXT STATE LOGIC
    always@(*)begin                             //Reference to the FSM Diagram will be helpful
        case(current_state)
            IDLE:  begin
                       if(transfer)
                            next_state = SETUP;
                        else 
                            next_state = IDLE;
                    end
            SETUP:  begin
                        next_state = ACCESS;
                    end
            ACCESS: begin
                        if(!PREADY)
                            next_state = ACCESS;
                        else if(PREADY && transfer)
                            next_state = SETUP;
                        else 
                            next_state = IDLE;
                    end
            default: next_state = IDLE;
        endcase  
    end
    
    //OUTPUT LOGIC
    always@(posedge PCLK or negedge rst_n)begin
        if(!rst_n)begin
            PSELx <= 1'b0;          //As per timing diagram, the transitions occur on the same clock cycle
            PENABLE <= 1'b0;        //There is no one-clock cycle delay in the assertions
            PADDR <= 32'b0;         //This is why we are using the Non Blocking statements, so that the transitions
            PWDATA <= 32'b0;        //can occur simultaneously, without any delay
            PWRITE <= 32'b0;
        end
        else begin
            case(next_state)
                IDLE: begin
                        PSELx <= 1'b0;          //No Slave Selected
                        PENABLE <= 1'b0;        //Master does not communicate with Slave
                      end
                SETUP: begin
                         PSELx <= 1'b1;         //Slave Selected
                         PENABLE <= 1'b0;       //ADDRESS PHASE
                         PADDR <= addr;         //address assigned
                         PWDATA <= wdata;       //data assigned
                         PWRITE <= write;       //Decides whether a read operation or write operation
                       end
               ACCESS: begin
                         PSELx <= 1'b1;         //Slave Selected
                         PENABLE <= 1'b1;       //DATA PHASE
                       end
            endcase
        end
    end
endmodule
