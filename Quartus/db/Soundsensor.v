module SoundSensor (
    input wire clk,        // Reloj del sistema
    input wire rst,        // Reset del sistema
    input wire sound_in,   // Entrada del sensor de sonido (DO)
    output reg sound_detected  // Señal de detección de sonido
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sound_detected <= 1'b0;
    end else begin
        // Detecta un cambio en la señal del sensor de sonido
        sound_detected <= sound_in;
    end
end

endmodule