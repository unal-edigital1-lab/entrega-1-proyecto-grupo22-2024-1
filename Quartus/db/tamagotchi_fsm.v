module tamagotchi_fsm (
    input wire clk,
    input wire rst,
    input wire boton_interaccion,
    input wire sensor_luz,
    input wire sensor_sonido,
    output reg [2:0] face,
    output reg [2:0] icon,
    output reg enable
);

// Definición de estados
localparam [2:0]
    SUENO       = 3'd0,
    HAMBRE      = 3'd1,
    HIGIENE     = 3'd2,
    FELICIDAD   = 3'd3,
    CONDICION   = 3'd4,
    MUERTO      = 3'd5;

// Registros para almacenar valores de estados
reg [2:0] valores_estados [4:0]; // [SUENO, HAMBRE, HIGIENE, FELICIDAD, CONDICION]
reg [2:0] salud;
reg [2:0] active_state;
reg [31:0] contador_tiempo;
reg [31:0] contador_sueno;
reg [31:0] contador_felicidad;
reg mascota_dormida;
reg boton_anterior;
reg boton_presionado;
reg accion_positiva;
reg accion_negativa;
reg felic_interaccion_activa;

integer i;

// Lógica de la FSM
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Inicialización
        for (i = 0; i < 5; i = i + 1) begin
            valores_estados[i] <= 3'd7;
        end
        salud <= 3'd7;
        active_state <= SUENO;
        contador_tiempo <= 0;
        contador_sueno <= 0;
        contador_felicidad <= 0;
        mascota_dormida <= 0;
        boton_anterior <= 0;
        boton_presionado <= 0;
        accion_positiva <= 0;
        accion_negativa <= 0;
        felic_interaccion_activa <= 0;
        face <= 3'd0;
        icon <= 3'd0;
        enable <= 1;
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
            if ((valores_estados[HAMBRE] == 0) || (valores_estados[HIGIENE] == 0) ||
                (valores_estados[FELICIDAD] == 0) || (valores_estados[CONDICION] == 0)) begin
                if (salud > 0)
                    salud <= salud - 1'd1;
            end
        end else begin
            contador_tiempo <= contador_tiempo + 1'd1;
        end
        
        // Lógica del botón de interacción
        if (boton_interaccion && !boton_anterior) begin
            case (active_state)
                SUENO: begin
                    // Si el sensor de luz está activo, no se permite dormir
                    if (!sensor_luz) begin
                        mascota_dormida <= ~mascota_dormida;
                        contador_sueno <= 0;
                    end else begin
                        accion_negativa <= 1; // Animación negativa
                    end
                end
                HAMBRE, HIGIENE, CONDICION: begin
                    if (valores_estados[active_state] == 0)
                        valores_estados[active_state] <= 2'd2;
                    else if (valores_estados[active_state] == 3'd7) begin
                        if (salud > 0)
                            salud <= salud - 1'd1;
                        accion_negativa <= 1;
                    end
                    else begin
                        valores_estados[active_state] <= valores_estados[active_state] + 1'd1;
                        accion_positiva <= 1;
                    end
                    
                    // Actualizar salud si el valor está entre 3 y 6
                    if (valores_estados[active_state] >= 3'd3 && valores_estados[active_state] <= 3'd6) begin
                        if (salud < 3'd7)
                            salud <= salud + 1'd1;
                    end
                end
                FELICIDAD: begin
                    felic_interaccion_activa <= 1; // Inicia la interacción en felicidad
                    contador_felicidad <= 0;
                end
            endcase
        end
        
        // Lógica de interacción de felicidad
        if (felic_interaccion_activa) begin
            if (contador_felicidad < 32'd30) begin // 30 segundos
                if (!boton_interaccion) begin
                    felic_interaccion_activa <= 0; // Se desactiva la interacción si el botón se suelta
                    accion_negativa <= 1; // Animación negativa
                end else if (sensor_sonido) begin
                    valores_estados[FELICIDAD] <= valores_estados[FELICIDAD] + 1'd1; // Aumenta felicidad
                    felic_interaccion_activa <= 0; // Termina la interacción
                    accion_positiva <= 1; // Animación positiva
                end
                contador_felicidad <= contador_felicidad + 1'd1;
            end else begin
                felic_interaccion_activa <= 0; // Tiempo expirado
                accion_negativa <= 1; // Animación negativa
            end
        end

        // Actualizar estado del botón anterior
        boton_anterior <= boton_interaccion;
        
        // Lógica para el estado de sueño
        if (active_state == SUENO && mascota_dormida) begin
            if (contador_sueno == 32'd300) begin // 5 minutos = 300 segundos
                contador_sueno <= 0;
                if (valores_estados[SUENO] < 3'd7)
                    valores_estados[SUENO] <= valores_estados[SUENO] + 1'd1;
            end else begin
                contador_sueno <= contador_sueno + 1'd1;
            end
        end
        
        // Cambio de estado activo
        if (!mascota_dormida && !felic_interaccion_activa) begin
            case (active_state)
                SUENO: active_state <= HAMBRE;
                HAMBRE: active_state <= HIGIENE;
                HIGIENE: active_state <= FELICIDAD;
                FELICIDAD: active_state <= CONDICION;
                CONDICION: active_state <= SUENO;
                default: active_state <= SUENO;
            endcase
        end
        
        // Lógica para determinar la cara (face)
        if (salud == 0)
            face <= 3'd5; // Mascota muerta
        else if (mascota_dormida)
            face <= 3'd3; // Mascota dormida
        else if (salud < 3'd3 && !mascota_dormida)
            face <= 3'd4; // Salud baja
        else if (accion_positiva)
            face <= 3'd1; // Animación positiva
        else if (accion_negativa)
            face <= 3'd2; // Animación negativa
        else
            face <= 3'd0; // Cara por defecto
        
        // Resetear flags de animación
        accion_positiva <= 0;
        accion_negativa <= 0;
        
        // Asignar icon basado en el estado activo
        icon <= active_state;
        
        // Habilitar visualización
        enable <= 1;
        
        // Cambio automático a estado MUERTO
        if (salud == 0) begin
            active_state <= MUERTO;
        end
    end
end

endmodule
