module tamagotchi_fsm (
    input wire clk,
    input wire rst,
    input wire change_state,
    input wire sensor_luz,
    input wire sensor_sonido,
    input wire boton_interaccion,
    output reg [2:0] active_state
);

// Definición de estados
localparam [2:0]
    SALUD        = 3'd0,
    HAMBRE       = 3'd1,
    FELICIDAD    = 3'd2,
    HIGIENE      = 3'd3,
    CONDICION    = 3'd4,
    SUENO        = 3'd5,
    MUERTO       = 3'd6;

// Registros para almacenar valores de estados
reg [2:0] valores_estados [5:0];
reg [31:0] contador_tiempo;
reg boton_anterior;

integer i;

// Lógica de la FSM
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Inicialización
        for (i = 0; i < 6; i = i + 1) begin
            valores_estados[i] <= 3'd7;
        end
        active_state <= SALUD;
        contador_tiempo <= 0;
        boton_anterior <= 0;
    end else begin
        // Lógica de tiempo (asumiendo un clk de 1Hz para simplificar)
        if (contador_tiempo == 32'd900) begin // 15 minutos = 900 segundos
            contador_tiempo <= 0;
            
            // Decrementar valores de estados
            for (i = 0; i < 5; i = i + 1) begin
                if (valores_estados[i] > 0)
                    valores_estados[i] <= valores_estados[i] - 1'd1;
            end
            
            // Lógica para decrementar salud
            if ((valores_estados[HAMBRE] == 0) || (valores_estados[FELICIDAD] == 0) ||
                (valores_estados[HIGIENE] == 0) || (valores_estados[CONDICION] == 0)) begin
                if (valores_estados[SALUD] > 0)
                    valores_estados[SALUD] <= valores_estados[SALUD] - 1'd1;
            end
        end else begin
            contador_tiempo <= contador_tiempo + 1'd1;
        end
        
        // Lógica de cambio de estado secuencial
        if (change_state) begin
            case (active_state)
                SALUD: active_state <= HAMBRE;
                HAMBRE: active_state <= FELICIDAD;
                FELICIDAD: active_state <= HIGIENE;
                HIGIENE: active_state <= CONDICION;
                CONDICION: active_state <= SALUD;
                default: active_state <= SALUD;
            endcase
        end
        
        // Lógica del botón de interacción
        if (boton_interaccion && !boton_anterior) begin
            case (active_state)
                SALUD: active_state <= SUENO;
                SUENO: active_state <= SALUD;
                HAMBRE, FELICIDAD, HIGIENE, CONDICION: begin
                    if (valores_estados[active_state] == 0)
                        valores_estados[active_state] <= 2'd2;
                    else if (valores_estados[active_state] == 3'd7) begin
                        if (valores_estados[SALUD] > 0)
                            valores_estados[SALUD] <= valores_estados[SALUD] - 1'd1;
                    end
                    else
                        valores_estados[active_state] <= valores_estados[active_state] + 1'd1;
                    
                    // Actualizar salud si el valor está entre 3 y 6
                    if (valores_estados[active_state] >= 3'd3 && valores_estados[active_state] <= 3'd6) begin
                        if (valores_estados[SALUD] < 3'd7)
                            valores_estados[SALUD] <= valores_estados[SALUD] + 1'd1;
                    end
                end
                default: ; // No hacer nada en otros estados
            endcase
        end
        
        // Actualizar estado del botón anterior
        boton_anterior <= boton_interaccion;
        
        // Cambio automático a estado MUERTO
        if (valores_estados[SALUD] == 0) begin
            active_state <= MUERTO;
        end
    end
end

endmodule