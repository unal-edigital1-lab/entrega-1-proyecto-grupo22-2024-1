module entradas_test (
    input wire [5:0] entradas,  // 6 entradas digitales
    output wire [5:0] leds      // 6 salidas LED
);

    // Asigna cada entrada directamente a su LED correspondiente
    assign leds = entradas;

endmodule