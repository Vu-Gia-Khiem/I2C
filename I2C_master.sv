// module I2C_master(
//     input clk, reset,
//     output logic i2c_sda, 
//     output logic i2c_scl
// );

// enum logic [3:0] {
//     ST_IDLE     = 4'd0,
//     ST_START    = 4'd1,
//     ST_ADDR     = 4'd2,
//     ST_RW       = 4'd3,
//     ST_ACK      = 4'd4,
//     ST_DATA     = 4'd5,
//     ST_ACK2     = 4'd6,
//     ST_STOP     = 4'd7
// } current_state, next_state;

// logic rw;
// logic ack, ack2;
// logic [6:0] addr;
// logic [7:0] data;
// logic [3:0] couter;

// always_ff @(posedge clk, negedge reset) begin
//     if(!reset) begin
//     // couter <= 4'd0;//////////////////////////////////////
//         current_state <= ST_IDLE;
//     end
//     else begin
//     // i2c_scl = clk;
//     // couter <= couter - 4'd1;
//         current_state <= next_state;
//     end
// end



// always_comb begin
//     case (current_state)
//         ST_IDLE: begin
//             i2c_sda = 1'b1;
//             i2c_scl = 1'b1;
//             rw      = 1'b0;     //  write
//             ack     = 1'b0;     // aaddr true
//             ack2    = 1'b0;     // transmit data done
//             addr    = 7'b1101011;
//             data    = 8'b00110011;
//             next_state = ST_START;

//         end

//         ST_START: begin
//             i2c_sda = 1'b0;
//             i2c_scl = 1'b0;
//             couter = 4'd6;
//             next_state = ST_ADDR;
//         end

//         ST_ADDR: begin
//         i2c_scl = clk;/////////////////////////////////////////////
//             i2c_sda = addr[couter];
//             if (couter == 4'd0) 
//             next_state = ST_RW;
//             else begin
//             couter = couter - 4'd1; 
//             end
//         end

//         ST_RW: begin
//         i2c_scl = clk;/////////////////////////////////////////////
//             i2c_sda = rw;
//             next_state = ST_ACK;
//         end

//         ST_ACK: begin
//         i2c_scl = clk;/////////////////////////////////////////////
//             i2c_sda = ack;
//             couter = 4'd7;
//             if (ack) begin
//                 next_state = ST_IDLE;
//             end
//             else begin
//                 next_state = ST_DATA;
//             end
//         end

//         ST_DATA: begin
//         i2c_scl = clk;/////////////////////////////////////////////
//                 i2c_sda = data[couter];
//                 if (couter == 4'd0) begin
//                     next_state = ST_ACK2;
//                 end
//                 else begin
//                 couter = couter - 4'd1; 
//                 end
//         end

//         ST_ACK2: begin
//         i2c_scl = clk;/////////////////////////////////////////////
//             i2c_sda = ack2;
//             if (ack) begin
//                 next_state = ST_DATA;
//             end
//             else begin
//             next_state = ST_STOP;
//             end
//         end

//         ST_STOP: begin
//             i2c_sda = 1'b1;
//             i2c_scl = 1'b1;
//             next_state = ST_IDLE;
//         end

//         default: i2c_scl = 1'b0;
//     endcase

// end

// endmodule : I2C_master




module I2C_master(
    input clk, reset,
    input rw, ack, ack2,
    input [6:0] addr,
    input [7:0] data_slave, data_master,
    output logic i2c_sda, 
    output logic i2c_scl
);

enum logic [3:0] {
    ST_IDLE     = 4'd0,
    ST_START    = 4'd1,
    ST_ADDR     = 4'd2,
    ST_RW       = 4'd3,
    ST_ACK      = 4'd4,
    ST_DATA_MASTER     = 4'd5,
    ST_DATA_SLAVE     = 4'd6,
    ST_ACK2     = 4'd7,
    ST_STOP     = 4'd8
} current_state, next_state;

// logic rw;
// logic ack, ack2;
// logic [6:0] addr;
// logic [7:0] data;
logic [3:0] couter;

always_ff @(posedge clk, negedge reset) begin
    if(!reset) begin
    // couter <= 4'd0;//////////////////////////////////////
        current_state <= ST_IDLE;
    end
    else begin
    // i2c_scl = clk;
    // couter <= couter - 4'd1;
        current_state <= next_state;
    end
end



always_comb begin
    case (current_state)
        ST_IDLE: begin
            i2c_sda = 1'b1;
            i2c_scl = 1'b1;
            couter  = 4'd0;
            // rw      = 1'b0;     //  write
            // ack     = 1'b0;     // aaddr true
            // ack2    = 1'b0;     // transmit data done
            // addr    = 7'b1101011;
            // data    = 8'b00110011;
            next_state = ST_START;

        end

        ST_START: begin
            i2c_sda = 1'b0;
            i2c_scl = 1'b0;
            couter = 4'd6;
            next_state = ST_ADDR;
        end

        ST_ADDR: begin
        i2c_scl = clk;/////////////////////////////////////////////
            i2c_sda = addr[couter];
            if (couter == 4'd0) 
            next_state = ST_RW;
            else begin
            couter = couter - 4'd1; 
            end
        end

        ST_RW: begin
        i2c_scl = clk;/////////////////////////////////////////////
            i2c_sda = rw;
            next_state = ST_ACK;
        end

        ST_ACK: begin
        i2c_scl = clk;/////////////////////////////////////////////
            i2c_sda = ack;
            couter = 4'd7;
            if ((ack == 1'b0) && (rw == 1'b0)) begin
                next_state = ST_DATA_MASTER;      /////// write
            end
            else if ((ack == 1'b0) && (rw == 1'b1)) begin
                next_state = ST_DATA_SLAVE;     /////// READ
            end
            else begin
                next_state = ST_IDLE;
            end
        end

        ST_DATA_MASTER: begin
        i2c_scl = clk;/////////////////////////////////////////////
                i2c_sda = data_master[couter];
                if (couter == 4'd0) begin
                    next_state = ST_ACK2;
                end
                else begin
                couter = couter - 4'd1; 
                end
        end

        ST_DATA_SLAVE: begin
        i2c_scl = clk;/////////////////////////////////////////////
                i2c_sda = data_slave[couter];
                if (couter == 4'd0) begin
                    next_state = ST_ACK2;
                end
                else begin
                couter = couter - 4'd1; 
                end
        end


        ST_ACK2: begin
        i2c_scl = clk;/////////////////////////////////////////////
            i2c_sda = ack2;
            if (ack2 == 1'b1 && rw == 1'b1) begin
                next_state = ST_DATA_SLAVE;
            end
	    else if (ack2 == 1'b1 && rw == 1'b0) begin
                next_state = ST_DATA_MASTER;	end        
            else begin
            next_state = ST_STOP;
            end
        end

        ST_STOP: begin
            i2c_sda = 1'b1;
            i2c_scl = 1'b1;
            next_state = ST_IDLE;
        end

        default: i2c_scl = 1'b0;
    endcase

end

endmodule : I2C_master




