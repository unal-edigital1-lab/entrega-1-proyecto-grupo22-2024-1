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
    output test_led,
    output buzzer_out
);

    // State parameters
    localparam SLEEP = 3'd0, FOOD = 3'd1, BATH = 3'd2, MUSIC = 3'd3, EXERCISE = 3'd4, DEAD = 3'd5;
     
    // Debounce instance
    wire b2_deb, b3_deb, b4_deb;
    debounce #(1500000) b2_debounce (.reset(reset), .clk(clk), .boton_in(b2), .boton_out(b2_deb));
    debounce #(1500000) b3_debounce (.reset(reset), .clk(clk), .boton_in(b3), .boton_out(b3_deb));
    debounce #(1500000) b4_debounce (.reset(reset), .clk(clk), .boton_in(b4), .boton_out(b4_deb));

    // Registers for states
    reg [2:0] sleep_state, food_state, bath_state, music_state, exercise_state, health_state;
    reg [2:0] current, face;
    reg [27:0] test_timer, face_timer, sleep_hold_timer, music_hold_timer;
    reg sleep_hold_active, music_hold_active, sound_detected;
    reg test_mode;
     
    assign test_led = !test_mode;

    // Timers (assuming 50MHz clock)
    // We'll use a 1-second base unit instead of real-time to speed up gameplay
    localparam ONE_SECOND = 50_000_000;  // Clock cycles in one second
    localparam SLEEP_TIME = 180;  // 180 seconds
    localparam FOOD_TIME = 60;  // 60 seconds
    localparam BATH_TIME = 120;  // 120 seconds
    localparam MUSIC_TIME = 90;  // 90 seconds
    localparam EXERCISE_TIME = 150; // 150 seconds
    
    localparam HOLD_TIME = 5 * ONE_SECOND;    // 5 seconds
    localparam FACE_TIME = 2 * ONE_SECOND;    // 2 seconds

    // State timers
    reg [27:0] second_counter;
    reg [7:0] sleep_timer, food_timer, bath_timer, music_timer, exercise_timer;

    // FSM_pet instance
    FSM_pet pet_display (
        .clk(clk),
        .reset(reset),
        .face(face),
        .icon(current),
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
	 
	 reg buzzer_trigger;
	 
	 buzzer #(
        .CLK_FREQ(50_000_000),
        .DURATION(1)
    ) buzzer_inst (
        .clk(clk),
        .reset(reset),
        .trigger(buzzer_trigger),
        .buzzer_out(buzzer_out)
    );

    // Update display data based on current mode
    always @(*) begin
        case (current)
            SLEEP:   display_data = {5'd13, 5'd14, 5'd15, 2'b0, sleep_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            FOOD:    display_data = {5'd10, 5'd11, 5'd12, 2'b0, food_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            BATH:    display_data = {5'd16, 5'd17, 5'd10, 2'b0, bath_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            MUSIC:   display_data = {5'd18, 5'd19, 5'd11, 2'b0, music_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            EXERCISE: display_data = {5'd18, 5'd20, 5'd17, 2'b0, exercise_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            default: display_data = {5'd21, 5'd22, 5'd23, 5'd21, 5'd21, 5'd22, 5'd23, 5'd21};
        endcase
    end

    // Detect rising edge of debounced buttons
    reg b2_prev, b3_prev, b4_prev;
    wire b2_posedge, b3_posedge, b4_posedge;
    
    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            b2_prev <= 0;
            b3_prev <= 0;
            b4_prev <= 0;
        end else begin
            b2_prev <= b2_deb;
            b3_prev <= b3_deb;
				b4_prev <= b4_deb;
        end
    end
    
    assign b2_posedge = b2_deb & ~b2_prev;
    assign b3_posedge = b3_deb & ~b3_prev;
	 assign b4_posedge = b4_deb & ~b4_prev;
    
    // Main logic including timer and state updates
    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            second_counter <= 0;
            sleep_state <= 3'd7;
            food_state <= 3'd7;
            bath_state <= 3'd7;
            music_state <= 3'd7;
            exercise_state <= 3'd7;
            health_state <= 3'd7;
            current <= SLEEP;
            face <= 0;
            test_mode <= 0;
            test_timer <= 0;
            sleep_timer <= 0;
            food_timer <= 0;
            bath_timer <= 0;
            music_timer <= 0;
            exercise_timer <= 0;
            face_timer <= 0;
            sleep_hold_timer <= 0;
            sleep_hold_active <= 0;
            music_hold_timer <= 0;
            music_hold_active <= 0;
            sound_detected <= 0;
				buzzer_trigger <= 0;
        end else begin
				buzzer_trigger <= 0;
            // Second counter logic
            if (second_counter < ONE_SECOND - 1) begin
                second_counter <= second_counter + 1;
            end else begin
                second_counter <= 0;
                
                // Increment state timers every second
                sleep_timer <= sleep_timer + 1;
                food_timer <= food_timer + 1;
                bath_timer <= bath_timer + 1;
                music_timer <= music_timer + 1;
                exercise_timer <= exercise_timer + 1;
            end

             // State updates
            if (sleep_timer >= SLEEP_TIME) begin
                sleep_timer <= 0;
                if (sleep_state == 3'd7) begin
                    sleep_state <= sleep_state - 1;
                    if (health_state < 3'd7) health_state <= health_state + 1;
                end else if (sleep_state > 0) begin
                    sleep_state <= sleep_state - 1;
                end else if (health_state > 0) begin
                    health_state <= health_state - 1;
                end
            end
            
            if (food_timer >= FOOD_TIME) begin
                food_timer <= 0;
                if (food_state == 3'd7) begin
                    food_state <= food_state - 1;
                    if (health_state < 3'd7) health_state <= health_state + 1;
                end else if (food_state > 0) begin
                    food_state <= food_state - 1;
                end else if (health_state > 0) begin
                    health_state <= health_state - 1;
                end
            end
            
            if (bath_timer >= BATH_TIME) begin
                bath_timer <= 0;
                if (bath_state == 3'd7) begin
                    bath_state <= bath_state - 1;
                    if (health_state < 3'd7) health_state <= health_state + 1;
                end else if (bath_state > 0) begin
                    bath_state <= bath_state - 1;
                end else if (health_state > 0) begin
                    health_state <= health_state - 1;
                end
            end
            
            if (music_timer >= MUSIC_TIME) begin
                music_timer <= 0;
                if (music_state == 3'd7) begin
                    music_state <= music_state - 1;
                    if (health_state < 3'd7) health_state <= health_state + 1;
                end else if (music_state > 0) begin
                    music_state <= music_state - 1;
                end else if (health_state > 0) begin
                    health_state <= health_state - 1;
                end
            end
            
            if (exercise_timer >= EXERCISE_TIME) begin
                exercise_timer <= 0;
                if (exercise_state == 3'd7) begin
                    exercise_state <= exercise_state - 1;
                    if (health_state < 3'd7) health_state <= health_state + 1;
                end else if (exercise_state > 0) begin
                    exercise_state <= exercise_state - 1;
                end else if (health_state > 0) begin
                    health_state <= health_state - 1;
                end
            end

            // Test mode logic
            if (b2_deb) begin
                if (test_timer == HOLD_TIME - 1) begin
                    test_mode <= ~test_mode;
                    test_timer <= 0;
                end else begin
                    test_timer <= test_timer + 1;
                end
            end else begin
                test_timer <= 0;
            end

            // Manual state changes (test mode)
            if (b2_posedge && test_mode) begin
                case (current)
                    SLEEP:   	if (sleep_state == 3'd7) begin
											sleep_state <= sleep_state - 1;
											if (health_state < 3'd7) health_state <= health_state + 1;
										end else if (sleep_state > 0) begin
											sleep_state <= sleep_state - 1;
										 end else if (health_state > 0) begin
											health_state <= health_state - 1;
										 end
										 
                    FOOD:    	if (food_state == 3'd7) begin
											food_state <= food_state - 1;
											if (health_state < 3'd7) health_state <= health_state + 1;
										end else if (food_state > 0) begin
											food_state <= food_state - 1;
										 end else if (health_state > 0) begin
											health_state <= health_state - 1;
										 end
										 
                    BATH:    	if (bath_state == 3'd7) begin
											bath_state <= bath_state - 1;
											if (health_state < 3'd7) health_state <= health_state + 1;
										end else if (bath_state > 0) begin
											bath_state <= bath_state - 1;
										 end else if (health_state > 0) begin
											health_state <= health_state - 1;
										 end
										 
                    MUSIC:   	if (music_state == 3'd7) begin
											music_state <= music_state - 1;
											if (health_state < 3'd7) health_state <= health_state + 1;
										end else if (music_state > 0) begin
											music_state <= music_state - 1;
										 end else if (health_state > 0) begin
											health_state <= health_state - 1;
										 end
										 
                    EXERCISE: if (exercise_state == 3'd7) begin
											exercise_state <= exercise_state - 1;
											if (health_state < 3'd7) health_state <= health_state + 1;
										end else if (exercise_state > 0) begin
											exercise_state <= exercise_state - 1;
										 end else if (health_state > 0) begin
											health_state <= health_state - 1;
										 end
                endcase
            end

            // Mode switching
            if (b3_posedge) begin
                case (current)
                    SLEEP: current <= FOOD;
                    FOOD: current <= BATH;
                    BATH: current <= MUSIC;
                    MUSIC: current <= EXERCISE;
                    EXERCISE: current <= SLEEP;
                    default: current <= SLEEP;
                endcase
            end
				
				// b4 logic
            if (b4_posedge) begin
                case (current)
                    FOOD: begin
                        if (food_state < 3'd7) begin
                            food_state <= food_state + 1;
                            face <= 1;
									 buzzer_trigger <= 1;
                            face_timer <= 0;
                        end else if (health_state > 0) begin
                            health_state <= health_state - 1;
                            face <= 2;
									 buzzer_trigger <= 1;
                            face_timer <= 0;
                        end
                    end
                    BATH: begin
                        if (bath_state < 3'd7) begin
                            bath_state <= bath_state + 1;
                            face <= 1;
									 buzzer_trigger <= 1;
                            face_timer <= 0;
                        end else if (health_state > 0) begin
                            health_state <= health_state - 1;
                            face <= 2;
									 buzzer_trigger <= 1;
                            face_timer <= 0;
                        end
                    end
                    EXERCISE: begin
                        if (exercise_state < 3'd7) begin
                            exercise_state <= exercise_state + 1;
                            face <= 1;
									 buzzer_trigger <= 1;
                            face_timer <= 0;
                        end else if (health_state > 0) begin
                            health_state <= health_state - 1;
                            face <= 2;
									 buzzer_trigger <= 1;
                            face_timer <= 0;
                        end
                    end
                endcase
            end
				
				// b4 logic for SLEEP
            if (current == SLEEP && !sleep_hold_active) begin
                if (b4_posedge && light_sensor) begin
                    face <= 3;
                    sleep_hold_active <= 1;
                    sleep_hold_timer <= 0;
                end
            end

            // timer for SLEEP
            if (sleep_hold_active) begin
                if (sleep_hold_timer < HOLD_TIME - 1) begin
                    sleep_hold_timer <= sleep_hold_timer + 1;
                end else begin
                    sleep_hold_active <= 0;
                    sleep_hold_timer <= 0;
                    
                    // Apply logic after HOLD_TIME
                    if (sleep_state < 3'd7) begin
                        sleep_state <= sleep_state + 1;
                        face <= 1;
								buzzer_trigger <= 1;
                        face_timer <= 0;
                    end else if (health_state > 0) begin
                        health_state <= health_state - 1;
                        face <= 2;
								buzzer_trigger <= 1;
                        face_timer <= 0;
                    end
                end
            end
				
				// b4 logic for MUSIC
            if (current == MUSIC && !music_hold_active) begin
                if (b4_posedge) begin
                    music_hold_active <= 1;
                    music_hold_timer <= 0;
                    sound_detected <= 0;
                end
            end

            // timer and logic for MUSIC
            if (music_hold_active) begin
                if (music_hold_timer < HOLD_TIME - 1) begin
                    music_hold_timer <= music_hold_timer + 1;
                    
                    // Sound check after 1s
                    if (music_hold_timer >= ONE_SECOND) begin
                        if (sound_sensor == 0 && !sound_detected) begin
                            sound_detected <= 1;
                        end
                    end
                end else begin
                    music_hold_active <= 0;
                    
                    // Logic if sound detected
                    if (sound_detected) begin
                        if (music_state < 3'd7) begin
                            music_state <= music_state + 1;
                            face <= 1;
									 buzzer_trigger <= 1;
                            face_timer <= 0;
                        end else if (health_state > 0) begin
                            health_state <= health_state - 1;
                            face <= 2;
									 buzzer_trigger <= 1;
                            face_timer <= 0;
                        end
                    end
                    music_hold_timer <= 0;
                    sound_detected <= 0;
                end
            end

            // Face timer logic
            if (current != DEAD && !sleep_hold_active) begin
                if (face_timer < FACE_TIME - 1) begin
                    face_timer <= face_timer + 1;
                end else if (face != 0) begin
                    if (health_state <= 3) begin
                        face <= 4;
                    end else begin
                        face <= 0;
                    end
                    face_timer <= 0;
                end
            end
				
				// Face update based on health
            if (current != DEAD && face != 1 && face != 2 && face != 3 && face != 5) begin
                if (health_state <= 3 && face != 4) begin
                    face <= 4;
                end else if (health_state > 3 && face == 4) begin
                    face <= 0;
                end
            end
				
            // Check if health reaches 0
            if (health_state == 0) begin
                current <= DEAD;
                face <= 5;
            end
        end
    end
endmodule