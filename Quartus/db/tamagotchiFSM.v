module tamagotchiFSM(
    input wire clk,
    input wire rst,
    input wire [2:0] change_state,
    output reg [2:0] active_state
);

// Definición de estados
localparam [2:0]
    SALUD        = 3'd0,
    HAMBRE       = 3'd1,
    SUENO        = 3'd2,
    FELICIDAD    = 3'd3,
    HIGIENE      = 3'd4,
    CONDICION    = 3'd5,
    MUERTO       = 3'd6;

// Registros para almacenar valores de estados
reg [2:0] valores_estados [5:0];
reg [31:0] contador_tiempo;

integer i; // Variable para el bucle for

// Lógica de la FSM
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Inicialización
        for (i = 0; i < 6; i = i + 1) begin
            valores_estados[i] <= 3'd7;
        end
        active_state <= SUENO;
        contador_tiempo <= 0;
    end else begin
        // Lógica de tiempo (asumiendo un clk de 1Hz para simplificar)
        if (contador_tiempo == 32'd900) begin // 15 minutos = 900 segundos
            contador_tiempo <= 0;
            
            // Decrementar valores de estados
            for (i = 1; i < 6; i = i + 1) begin
                if (valores_estados[i] > 0)
                    valores_estados[i] <= valores_estados[i] - 1'd1;
            end
            
            // Lógica para decrementar salud
            if ((valores_estados[HAMBRE] == 0) || (valores_estados[SUENO] == 0) ||
                (valores_estados[FELICIDAD] == 0) || (valores_estados[HIGIENE] == 0) ||
                (valores_estados[CONDICION] == 0)) begin
                if (valores_estados[SALUD] > 0)
                    valores_estados[SALUD] <= valores_estados[SALUD] - 1'd1;
            end
        end else begin
            contador_tiempo <= contador_tiempo + 1'd1;
        end
        
        // Cambio de estado activo
        if (change_state != 3'd7) begin // 3'd7 es un valor no usado para indicar "sin cambio"
            active_state <= change_state;
        end
        
        // Cambio automático a estado MUERTO
        if (valores_estados[SALUD] == 0) begin
            active_state <= MUERTO;
        end
    end
end

endmodule