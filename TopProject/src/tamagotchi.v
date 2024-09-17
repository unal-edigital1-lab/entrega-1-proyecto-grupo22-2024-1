module tamagotchi (
    input clk,
    input reset,
    input b2, b3, b4,
    input light_sensor,
    input sound_sensor,
    output mosi,
    output sclk,
    output ce,
    output dc,
    output lcd_rst,
    output [0:6] sseg,
    output [7:0] an,
	 output test_led
);

    // State parameters
    localparam SLEEP = 3'd0, FOOD = 3'd1, BATH = 3'd2, MUSIC = 3'd3, EXERCISE = 3'd4, DEAD = 3'd5;
    
    // Face parameters
    localparam NORMAL = 3'd0, HAPPY = 3'd1, SAD = 3'd2, SLEEPY = 3'd3, SICK = 3'd4, DEAD_FACE = 3'd5;

    // Registers for states
    reg [3:0] sleep_state, food_state, bath_state, music_state, exercise_state, health_state;
    reg [2:0] current_mode, face;
    reg [31:0] timer, test_timer;
    reg test_mode, enable;
	 
	 assign test_led = !test_mode;

    // Timers (assuming 50MHz clock)
    localparam SLEEP_TIME = 30 * 60 * 50_000_000;  // 30 minutes
    localparam FOOD_TIME = 10 * 60 * 50_000_000;   // 10 minutes
    localparam BATH_TIME = 20 * 60 * 50_000_000;   // 20 minutes
    localparam MUSIC_TIME = 15 * 60 * 50_000_000;  // 15 minutes
    localparam EXERCISE_TIME = 25 * 60 * 50_000_000; // 25 minutes
    
    localparam TEST_HOLD_TIME = 5 * 50_000_000;    // 5 seconds
    localparam FACE_CHANGE_TIME = 1 * 50_000_000;  // 1 second
    localparam SLEEPY_TIME = 5 * 50_000_000;       // 5 seconds

    // FSM_pet instance
    FSM_pet pet_display (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .face(face),
        .icon(current_mode),
        .mosi(mosi),
        .sclk(sclk),
        .ce(ce),
        .dc(dc),
        .lcd_rst(lcd_rst)
    );

    // 7-segment display data
    reg [39:0] display_data;

    // display_hex instance
    display_hex seg_display (
        .num(display_data),
        .clk(clk),
        .sseg(sseg),
        .an(an),
        .rst(reset)
    );

    // Update display data based on current mode
    always @(*) begin
        case (current_mode)
            SLEEP:   display_data = {5'd13, 5'd14, 5'd15, 1'b0, sleep_state[3:0], 5'd10, 5'd14, 5'd17, 1'b0, health_state[3:0]};
            FOOD:    display_data = {5'd10, 5'd13, 5'd12, 1'b0, food_state[3:0], 5'd10, 5'd14, 5'd17, 1'b0, health_state[3:0]};
            BATH:    display_data = {5'd16, 5'd17, 5'd10, 1'b0, bath_state[3:0], 5'd10, 5'd14, 5'd17, 1'b0, health_state[3:0]};
            MUSIC:   display_data = {5'd18, 5'd19, 5'd13, 1'b0, music_state[3:0], 5'd10, 5'd14, 5'd17, 1'b0, health_state[3:0]};
            EXERCISE: display_data = {5'd20, 5'd21, 5'd20, 1'b0, exercise_state[3:0], 5'd10, 5'd14, 5'd17, 1'b0, health_state[3:0]};
            default: display_data = {5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 5'd10, 5'd14, 5'd17, 1'b0, health_state[3:0]};
        endcase
    end

    // Main logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sleep_state <= 4'd9;
            food_state <= 4'd9;
            bath_state <= 4'd9;
            music_state <= 4'd9;
            exercise_state <= 4'd9;
            health_state <= 4'd9;
            current_mode <= SLEEP;
            face <= NORMAL;
            timer <= 0;
            test_mode <= 0;
            test_timer <= 0;
            enable <= 1;
				
        end else begin
            // Test mode toggle
            if (b2) begin
                if (test_timer == TEST_HOLD_TIME - 1) begin
                    test_mode <= ~test_mode;
                    test_timer <= 0;
                end else begin
                    test_timer <= test_timer + 1;
                end
            end else begin
                test_timer <= 0;
            end

            // Mode switching
            if (b3 && current_mode != DEAD) begin
					enable <= 0;
                case (current_mode)
                    SLEEP: current_mode <= FOOD;
                    FOOD: current_mode <= BATH;
                    BATH: current_mode <= MUSIC;
                    MUSIC: current_mode <= EXERCISE;
                    EXERCISE: current_mode <= SLEEP;
                endcase
                enable <= 1;
            end else begin
            end

            // State logic
            case (current_mode)
                SLEEP: begin
                    if (b4 && light_sensor == 0) begin
                        face <= SLEEPY;
                        timer <= SLEEPY_TIME;
                    end else if (timer == 1) begin
                        if (sleep_state == 0) begin
                            sleep_state <= sleep_state + 2;
                            face <= HAPPY;
                        end else if (sleep_state >= 1 && sleep_state <= 6) begin
                            sleep_state <= sleep_state + 1;
                            face <= HAPPY;
                        end else if (sleep_state == 7) begin
                            health_state <= health_state - 1;
                            face <= SAD;
                        end
                        timer <= FACE_CHANGE_TIME;
                    end else if (timer == 0) begin
                        face <= NORMAL;
                    end
                end
                
                FOOD: begin
                    if (b4) begin
                        if (food_state == 0) begin
                            food_state <= food_state + 2;
                            face <= HAPPY;
                        end else if (food_state >= 1 && food_state <= 6) begin
                            food_state <= food_state + 1;
                            face <= HAPPY;
                        end else if (food_state == 7) begin
                            health_state <= health_state - 1;
                            face <= SAD;
                        end
                        timer <= FACE_CHANGE_TIME;
                    end else if (timer == 0) begin
                        face <= NORMAL;
                    end
                end
                
                BATH: begin
                    if (b4) begin
                        if (bath_state == 0) begin
                            bath_state <= bath_state + 2;
                            face <= HAPPY;
                        end else if (bath_state >= 1 && bath_state <= 6) begin
                            bath_state <= bath_state + 1;
                            face <= HAPPY;
                        end else if (bath_state == 7) begin
                            health_state <= health_state - 1;
                            face <= SAD;
                        end
                        timer <= FACE_CHANGE_TIME;
                    end else if (timer == 0) begin
                        face <= NORMAL;
                    end
                end
                
                MUSIC: begin
                    if (sound_sensor) begin
                        if (music_state == 0) begin
                            music_state <= music_state + 2;
                            face <= HAPPY;
                        end else if (music_state >= 1 && music_state <= 6) begin
                            music_state <= music_state + 1;
                            face <= HAPPY;
                        end else if (music_state == 7) begin
                            health_state <= health_state - 1;
                            face <= SAD;
                        end
                        timer <= FACE_CHANGE_TIME;
                    end else if (timer == 0) begin
                        face <= NORMAL;
                    end
                end
                
                EXERCISE: begin
                    if (b4) begin
                        if (exercise_state == 0) begin
                            exercise_state <= exercise_state + 2;
                            face <= HAPPY;
                        end else if (exercise_state >= 1 && exercise_state <= 6) begin
                            exercise_state <= exercise_state + 1;
                            face <= HAPPY;
                        end else if (exercise_state == 7) begin
                            health_state <= health_state - 1;
                            face <= SAD;
                        end
                        timer <= FACE_CHANGE_TIME;
                    end else if (timer == 0) begin
                        face <= NORMAL;
                    end
                end
            endcase

            // Timer logic
            if (timer > 0) begin
                timer <= timer - 1;
            end else begin
                if (test_mode && b2) begin
                    case (current_mode)
                        SLEEP: timer <= SLEEP_TIME - 1;
                        FOOD: timer <= FOOD_TIME - 1;
                        BATH: timer <= BATH_TIME - 1;
                        MUSIC: timer <= MUSIC_TIME - 1;
                        EXERCISE: timer <= EXERCISE_TIME - 1;
                    endcase
                end else begin
                    timer <= timer + 1;
                    case (current_mode)
                        SLEEP: if (timer == SLEEP_TIME - 1) update_state(sleep_state);
                        FOOD: if (timer == FOOD_TIME - 1) update_state(food_state);
                        BATH: if (timer == BATH_TIME - 1) update_state(bath_state);
                        MUSIC: if (timer == MUSIC_TIME - 1) update_state(music_state);
                        EXERCISE: if (timer == EXERCISE_TIME - 1) update_state(exercise_state);
                    endcase
                end
            end

            // Health check
            if (health_state <= 3 && health_state > 0) begin
                face <= SICK;
            end else if (health_state == 0) begin
                face <= DEAD_FACE;
                current_mode <= DEAD;
            end
        end
    end

    // Task to update states
    task update_state;
        input [3:0] state;
        begin
            case (state)
                0: health_state <= health_state - 1;
                1, 2, 3: state <= state - 1;
                4, 5, 6: state <= state - 2;
                7: begin
                    state <= state - 2;
                    if (health_state < 9) health_state <= health_state + 1;
                end
            endcase
        end
    endtask

endmodule