module LightSensor (
    input wire clk,         // Reloj de la FPGA
    input wire rst,         // Señal de reset
    input wire DO,          // Entrada del sensor de luz (Digital Output)
    output reg light_detected // Señal de salida procesada (1 bit)
);

// Procesamiento de la señal del sensor
always @(posedge clk or posedge rst) begin
    if (rst) begin
        light_detected <= 1'b0;
    end else begin
        light_detected <= DO; // Simplemente pasa la señal del sensor
    end
end

endmodule
