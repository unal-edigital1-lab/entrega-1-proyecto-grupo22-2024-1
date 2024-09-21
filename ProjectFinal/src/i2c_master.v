module i2c_master ( 
    input wire clk,
    input wire reset_n,
    input wire sync_reset,
    input wire internal_clk,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    input wire read_enable,
    input wire write_enable,
    output reg nack,
    output reg queued,
    output reg data_valid,
    output reg stop,
    output reg [2:0] status,
    input wire scl_in,
    output reg scl_out,
    input wire sda_in,
    output reg sda_out
);

    parameter DEVICE_ADDRESS = 8'h68;

    // State definition
    parameter IDLE = 5'b00000,
              START = 5'b00001,
              SEND_BIT = 5'b00010,
              WAIT_SCL_HIGH = 5'b00011,
              WAIT_SCL_LOW = 5'b00100,
              CHECK_ACK = 5'b00101,
              CHECK_ACK_HIGH = 5'b00110,
              CHECK_ACK_LOW = 5'b00111,
              WRITE = 5'b01000,
              PREP_STOP = 5'b01001,
              STOP = 5'b01010,
              READ = 5'b01011,
              RECEIVE_BIT = 5'b01100,
              RD_SCL_HIGH = 5'b01101,
              RD_SCL_LOW = 5'b01110,
              SEND_ACK = 5'b01111,
              SEND_ACK_HIGH = 5'b10000,
              SEND_ACK_LOW = 5'b10001,
              RESTART = 5'b10010;

    // State variables
    reg [4:0] state, next_state;
    reg [3:0] counter, next_counter;
    reg [7:0] shift;
    reg nack_detected;
    reg sda_in_q, sda_in_qq;

    // Combinational logic for counter
    always @(*) begin
        next_counter = counter + 1;
    end

    // Sequential logic for SDA_IN capture register
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sda_in_q <= 1'b1;
            sda_in_qq <= 1'b1;
        end else if (clk) begin
            sda_in_q <= sda_in;
            sda_in_qq <= sda_in_q;
        end
    end

    // Main sequential logic for state machine
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            status <= 3'b000;
            state <= IDLE;
            scl_out <= 1'b1;
            sda_out <= 1'b1;
            nack <= 1'b0;
            queued <= 1'b0;
            data_valid <= 1'b0;
            data_out <= 8'b0;
            counter <= 4'b0;
            nack_detected <= 1'b0;
            shift <= 8'b0;
            stop <= 1'b0;
        end else if (clk) begin
            if (sync_reset) begin
                state <= IDLE;
            end else begin
                case (state)
                    IDLE: begin
                        status <= 3'b000;
                        scl_out <= 1'b1;
                        sda_out <= 1'b1;
                        nack <= 1'b0;
                        queued <= 1'b0;
                        data_valid <= 1'b0;
                        data_out <= 8'h01;
                        counter <= 4'b0;
                        stop <= 1'b0;
                        if (internal_clk) begin
                            if (write_enable || read_enable) begin
                                state <= START;
                            end
                        end
                    end
                    START: begin
                        status <= 3'b001;
                        scl_out <= 1'b1;
                        sda_out <= 1'b0;
                        nack <= 1'b0;
                        queued <= 1'b0;
                        stop <= 1'b0;
                        data_valid <= 1'b0;
                        if (internal_clk) begin
                            scl_out <= 1'b0;
                            counter <= 4'b0000;
                            shift[7:1] <= DEVICE_ADDRESS[6:0];
                            if (write_enable) begin
                                shift[0] <= 1'b0;
                                next_state <= WRITE; 
                            end else begin
                                shift[0] <= 1'b1;
                                next_state <= READ;
                            end
                            state <= SEND_BIT;
                        end
                    end
                    SEND_BIT: begin
                        if (internal_clk) begin
                            status <= 3'b010;
                            scl_out <= 1'b0;
                            sda_out <= shift[7];
                            shift[7:1] <= shift[6:0];
                            counter <= next_counter; 
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            state <= WAIT_SCL_HIGH;
                        end
                    end
                    WAIT_SCL_HIGH: begin
                        if (internal_clk) begin
                            nack <= 1'b0;
                            queued <= 1'b0;
                            data_valid <= 1'b0;
                            scl_out <= 1'b1;
                            state <= WAIT_SCL_LOW;
                        end
                    end
                    WAIT_SCL_LOW: begin
                        if (internal_clk) begin
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            scl_out <= 1'b0;
                            if (counter[3]) begin
                                state <= CHECK_ACK;
                            end else begin
                                state <= SEND_BIT;
                            end
                        end
                    end
                    CHECK_ACK: begin
                        if (internal_clk) begin
                            status <= 3'b011;
                            sda_out <= 1'b1;
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            scl_out <= 1'b0;
                            state <= CHECK_ACK_HIGH;    
                        end
                    end
                    CHECK_ACK_HIGH: begin
                        if (internal_clk) begin
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            scl_out <= 1'b1;
                            nack_detected <= (sda_in_qq == 1'b1) ? 1'b1 : 1'b0;
                            state <= CHECK_ACK_LOW;    
                        end
                    end
                    CHECK_ACK_LOW: begin
                        if (internal_clk) begin
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            scl_out <= 1'b0;
                            state <= next_state;
                        end
                    end
                    WRITE: begin
                        if (nack_detected) begin
                            nack <= 1'b1;
                            scl_out <= 1'b0;
                            if (internal_clk) begin
                                nack_detected <= 1'b0;
                                sda_out <= 1'b0;
                                state <= PREP_STOP;
                            end
                        end else begin
                            if (write_enable) begin
                                shift <= data_in;
                                counter <= 4'b0000;
                                queued <= 1'b1;
                                data_valid <= 1'b0;
                                state <= SEND_BIT;
                            end else if (read_enable) begin    
                                scl_out <= 1'b0;
                                sda_out <= 1'b1;
                                if (internal_clk) begin
                                    state <= RESTART;
                                end
                            end else begin
                                scl_out <= 1'b0;
                                if (internal_clk) begin
                                    sda_out <= 1'b0;
                                    state <= PREP_STOP;
                                end
                            end
                        end
                    end
                    RESTART: begin
                        if (internal_clk) begin
                            state <= IDLE;
                        end
                    end
                    READ: begin
                        if (nack_detected) begin
                            nack <= 1'b1;
                            scl_out <= 1'b0;
                            if (internal_clk) begin
                                nack_detected <= 1'b0;
                                sda_out <= 1'b0;
                                state <= PREP_STOP;
                            end
                        end else begin
                            if (read_enable) begin
                                shift <= 8'b0;
                                counter <= 4'b0000;
                                queued <= 1'b1;
                                state <= RECEIVE_BIT;
                            end else if (write_enable) begin    
                                scl_out <= 1'b0;
                                sda_out <= 1'b1;
                                if (internal_clk) begin
                                    state <= IDLE;
                                end
                            end else begin
                                scl_out <= 1'b0;
                                if (internal_clk) begin
                                    sda_out <= 1'b0;
                                    state <= PREP_STOP;
                                end
                            end
                        end
                    end
                    RECEIVE_BIT: begin
                        if (internal_clk) begin
                            status <= 3'b101;
                            sda_out <= 1'b1;
                            scl_out <= 1'b0;
                            counter <= next_counter; 
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            state <= RD_SCL_HIGH;
                        end
                    end
                    RD_SCL_HIGH: begin
                        if (internal_clk) begin
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            scl_out <= 1'b1;
                            shift[7:1] <= shift[6:0];
                            shift[0] <= sda_in_qq;
                            state <= RD_SCL_LOW;
                        end
                    end
                    RD_SCL_LOW: begin
                        if (internal_clk) begin
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            scl_out <= 1'b0;
                            if (counter[3]) begin
                                state <= SEND_ACK;
                            end else begin
                                state <= RECEIVE_BIT;
                            end
                        end
                    end
                    SEND_ACK: begin
                        if (internal_clk) begin
                            status <= 3'b110;
                            sda_out <= (read_enable) ? 1'b0 : 1'b1;
                            data_out <= shift;
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b1;
                            scl_out <= 1'b0;
                            state <= SEND_ACK_HIGH;
                        end
                    end
                    SEND_ACK_HIGH: begin
                        if (internal_clk) begin
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            scl_out <= 1'b1;
                            state <= SEND_ACK_LOW;
                        end
                    end
                    SEND_ACK_LOW: begin
                        if (internal_clk) begin
                            nack <= 1'b0;
                            queued <= 1'b0;
                            stop <= 1'b0;
                            data_valid <= 1'b0;
                            scl_out <= 1'b0;
                            state <= READ;
                        end
                    end
                    PREP_STOP: begin
                        if (internal_clk) begin
                            status <= 3'b111;
                            stop <= 1'b1;
                            scl_out <= 1'b1;
                            sda_out <= 1'b0;
                            nack <= 1'b0;
                            state <= STOP;
                        end
                    end
                    STOP: begin
                        if (internal_clk) begin
                            scl_out <= 1'b1;
                            sda_out <= 1'b1;
                            state <= IDLE;
                        end
                    end
                    default: state <= IDLE;
                endcase
            end
        end
    end

endmodule