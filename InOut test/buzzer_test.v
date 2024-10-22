module buzzer_test(
    input clk,
    input reset,
    input trigger,
    output reg buzzer_out
);

    // Parámetros
    parameter CLK_FREQ = 50_000_000;  // Frecuencia del reloj (50 MHz)
    parameter DURATION = 2;           // Duración del sonido en segundos

    // Registros internos
    reg [31:0] counter;
    reg trigger_prev;
    reg active;

    // Detectar flanco de subida de la señal de disparo
    wire trigger_posedge = trigger & ~trigger_prev;

    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            counter <= 0;
            trigger_prev <= 0;
            active <= 0;
            buzzer_out <= 1;  // Inicialmente inactivo (alto)
        end else begin
            trigger_prev <= trigger;

            if (trigger_posedge) begin
                active <= 1;
                counter <= 0;
                buzzer_out <= 0;  // Activa el buzzer (bajo)
            end else if (active) begin
                if (counter < CLK_FREQ * DURATION - 1) begin
                    counter <= counter + 1;
                end else begin
                    active <= 0;
                    buzzer_out <= 1;  // Desactiva el buzzer (alto)
                end
            end
        end
    end

endmodule