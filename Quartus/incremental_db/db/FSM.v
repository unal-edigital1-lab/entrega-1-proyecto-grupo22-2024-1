module TamagotchiFSM (
    input wire clk,
    input wire rst,
    input wire light_detected,
    input wire sound_detected,
    input wire movement_detected,
    output reg [1:0] tamagotchi_state
);

// Definición de estados
localparam SLEEPING = 2'b00;
localparam AWAKE = 2'b01;
localparam PLAYING = 2'b10;
localparam HUNGRY = 2'b11;

reg [1:0] current_state, next_state;

// Lógica de transición de estados
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= SLEEPING;
    end else begin
        current_state <= next_state;
    end
end

// Lógica de siguiente estado y salida
always @(*) begin
    next_state = current_state;
    case (current_state)
        SLEEPING: begin
            if (light_detected || sound_detected || movement_detected)
                next_state = AWAKE;
        end
        AWAKE: begin
            if (!light_detected)
                next_state = SLEEPING;
            else if (sound_detected)
                next_state = PLAYING;
            else if (movement_detected)
                next_state = HUNGRY;
        end
        PLAYING: begin
            if (!sound_detected)
                next_state = AWAKE;
        end
        HUNGRY: begin
            if (!movement_detected)
                next_state = AWAKE;
        end
    endcase
    tamagotchi_state = current_state;
end

endmodule
