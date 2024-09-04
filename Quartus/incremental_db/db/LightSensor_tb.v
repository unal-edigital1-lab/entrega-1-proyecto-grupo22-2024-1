`timescale 1ns / 1ps

module LightSensor_tb;

reg clk;
reg rst;
reg DO;
wire light_detected;

// Instanciar el módulo a probar
LightSensor uut (
    .clk(clk),
    .rst(rst),
    .DO(DO),
    .light_detected(light_detected)
);

// Generación de la señal de reloj
always #5 clk = ~clk; // Período de 10ns

// Secuencia de prueba
initial begin
    // Inicialización
    clk = 0;
    rst = 1;
    DO = 0;
    
    // Quitar reset después de 20ns
    #20 rst = 0;
    
    // Simulación de entrada del sensor
    #30 DO = 1; // Luz detectada
    #40 DO = 0; // Luz no detectada
    #50 DO = 1; // Luz detectada nuevamente
    
    // Finalizar simulación
    #100 $finish;
end

// Monitorear las señales
initial begin
    $monitor("Time=%0d clk=%b rst=%b DO=%b light_detected=%b", $time, clk, rst, DO, light_detected);
end

endmodule
