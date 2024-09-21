module movement_detect (
    input wire clk,
    input wire reset_n,
    input wire internal_clk,
    input wire completed,
    output reg rescan,
    input wire [7:0] x_reg,
    output reg movement
);
    // Magnitude function
    function [7:0] magnitude;
        input [7:0] a;
        reg [7:0] ret;
        begin
            if (a[7] == 1'b1) begin
                ret = ~a + 1'b1;
            end else begin
                ret = a;
            end
            magnitude = ret;
        end
    endfunction

    // Calculate magnitude of x_reg
    wire [7:0] x_magnitude = magnitude(x_reg);

    // magnitude bigger than threshold
    wire x_greater = (x_magnitude > 80) ? 1'b1 : 1'b0;

    wire active = x_greater;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            movement <= 1'b1;
            rescan <= 1'b0;
        end else begin
            if (internal_clk) begin
                if (completed) begin
                    movement <= 1'b0;
                    if (active) begin
                        movement <= ~x_reg[7];
                    end
                    rescan <= 1'b1;
                end else begin
                    rescan <= 1'b0;
                end
            end
        end
    end
endmodule