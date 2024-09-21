module mpu6050_controller (
    input wire clk,
    input wire reset_n,
    input wire internal_clk,
    output reg sync_reset,
    output reg [7:0] data_out,
    output reg read_enable,
    output reg write_enable,
    input wire queued,
    input wire nack,
    input wire stop,
    input wire data_valid,
    input wire [7:0] data_in,
    output reg [3:0] address,
    output reg [7:0] data,
    output reg load,
    output reg completed,
    input wire rescan
);

    // State definitions
    localparam IDLE = 3'b000,
               POWER_MGMT_0 = 3'b001,
               POWER_MGMT_1 = 3'b010,
               READ_0 = 3'b011,
               READ_1 = 3'b100,
               STABLE = 3'b101;

    // State variable
    reg [2:0] state = 0;
    reg [3:0] address_internal;

    // State machine
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sync_reset <= 1'b0;
            data_out <= 8'b0;
            read_enable <= 1'b0;
            write_enable <= 1'b0;
            address_internal <= 4'b0;
            load <= 1'b0;
            data <= 8'b11111111;
            completed <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (internal_clk) begin
                        sync_reset <= 1'b0;
                        data_out <= 8'b0;
                        read_enable <= 1'b0;
                        write_enable <= 1'b0;
                        address_internal <= 4'b0;
                        load <= 1'b0;
                        data <= 8'b11111111;
                        completed <= 1'b0;
                        state <= POWER_MGMT_0;
                    end
                end
                POWER_MGMT_0: begin
                    if (internal_clk) begin
                        data_out <= 8'h6B;
                        write_enable <= 1'b1;
                        read_enable <= 1'b0;
                        if (queued) begin
                            data_out <= 8'h00;
                            write_enable <= 1'b1;
                            read_enable <= 1'b0;
                            state <= POWER_MGMT_1;
                        end else if (nack) begin
                            state <= IDLE;
                        end
                    end
                end
                POWER_MGMT_1: begin
                    if (internal_clk) begin
                        if (queued) begin
                            data_out <= 8'h00;
                            write_enable <= 1'b0;
                            read_enable <= 1'b0;
                            state <= READ_0;
                        end else if (nack) begin
                            state <= IDLE;
                        end
                    end
                end
                READ_0: begin    
                    if (internal_clk) begin
                        if (stop) begin
                            data_out <= 8'h3B;
                            write_enable <= 1'b1;
                            read_enable <= 1'b0;
                        end else if (queued) begin
                            write_enable <= 1'b0;
                            read_enable <= 1'b1;
                            address_internal <= 4'b0;
                        end else if (data_valid) begin
                            load <= 1'b1;
                            data <= data_in;
                            state <= READ_1;
                        end else if (nack) begin
                            state <= IDLE;
                        end    
                    end
                end
                READ_1: begin
                    if (internal_clk) begin
                        if (data_valid) begin
                            load <= 1'b1;
                            data <= data_in;
                        end else if (queued) begin
                            address_internal <= address_internal + 1;
                            if (address_internal == 4'b1100) begin
                                write_enable <= 1'b0;
                                read_enable <= 1'b0;
                            end else begin
                                write_enable <= 1'b0;
                                read_enable <= 1'b1;
                            end
                        end else if (stop) begin
                            state <= STABLE;
                        end else begin
                            load <= 1'b0;
                        end
                    end
                end
                STABLE: begin
                    completed <= 1'b1;
                    if (internal_clk) begin
                        if (rescan) begin
                            state <= IDLE;
                        end
                    end
                end
            endcase
        end
    end

    // Continuous assignment of address to internal address register
    always @* begin
        address = address_internal;
    end

endmodule