`timescale 1ns / 1ps  //no se pa que sirve poner esto pero asi ponian xD

module button_driver(
    input clk,
    input btn1,
    input btn2,
    output reg btn1_pressed,
    output reg btn2_pressed
);

parameter DEBOUNCE_CYCLES = 10000; // Valor de Nciclos de reloj para leer entrada.

reg [15:0] btn1_debounce_counter;
reg [15:0] btn2_debounce_counter;

always @(posedge clk) begin
    // Botón 1
    if (btn1 == 1'b0) begin
        if (btn1_debounce_counter < DEBOUNCE_CYCLES) begin
            btn1_debounce_counter <= btn1_debounce_counter + 1;
        end else begin
            btn1_pressed <= 1'b1;
        end
    end else begin
        btn1_debounce_counter <= 0;
        btn1_pressed <= 1'b0;
    end

    // Botón 2 
    if (btn2 == 1'b0) begin
        if (btn2_debounce_counter < DEBOUNCE_CYCLES) begin
            btn2_debounce_counter <= btn2_debounce_counter + 1;
        end else begin
            btn2_pressed <= 1'b1;
        end
    end else begin
        btn2_debounce_counter <= 0;
        btn2_pressed <= 1'b0;
    end
end

endmodule