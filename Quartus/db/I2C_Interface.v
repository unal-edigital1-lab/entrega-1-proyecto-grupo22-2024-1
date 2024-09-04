module I2C_Interface (
    input wire clk,
    input wire rst,
    inout wire i2c_sda,  // Serial Data Line
    output reg i2c_scl,  // Serial Clock Line
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    output reg done
);

// Implementación básica del protocolo I2C
// Código específico se agregará según los requerimientos de tu aplicación

endmodule