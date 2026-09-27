// Snake Game Logic - Separated for modularity
// Classic snake with grid-based movement, growth, collision detection
// C++17 compatible

#pragma once

#include <vector>
#include <random>
#include <algorithm>
#include <string>
#include <cstdio>

struct SnakeSegment {
    int x, y;
    SnakeSegment() : x(0), y(0) {}
    SnakeSegment(int x_, int y_) : x(x_), y(y_) {}
    bool operator==(const SnakeSegment& other) const {
        return x == other.x && y == other.y;
    }
};

enum class SnakeDirection {
    UP, DOWN, LEFT, RIGHT
};

class SnakeGame {
public:
    struct Config {
        Config() : grid_width(20), grid_height(20), cell_size(24.0f), initial_length(3), base_speed_ms(120) {}
        int grid_width;
        int grid_height;
        float cell_size;
        int initial_length;
        int base_speed_ms;
    };
    
    struct State {
        State() : direction(SnakeDirection::RIGHT), next_direction(SnakeDirection::RIGHT), 
                  food(-1, -1), score(0), high_score(0), game_over(false), paused(false),
                  accumulator(0.0f), step_time(0.12f), food_pulse(0.0f) {}
        std::vector<SnakeSegment> body;
        SnakeDirection direction;
        SnakeDirection next_direction;
        SnakeSegment food;
        int score;
        int high_score;
        bool game_over;
        bool paused;
        float accumulator;
        float step_time;
        float food_pulse;
    };
    
    Config config;
    State state;
    std::mt19937 rng;
    
    SnakeGame(const Config& cfg = Config()) : config(cfg), rng(std::random_device{}()) {
        load_high_score();
        reset();
    }
    
    void reset() {
        state.body.clear();
        int start_x = config.grid_width / 2;
        int start_y = config.grid_height / 2;
        for (int i = 0; i < config.initial_length; ++i) {
            state.body.emplace_back(start_x - i, start_y);
        }
        state.direction = SnakeDirection::RIGHT;
        state.next_direction = SnakeDirection::RIGHT;
        state.score = 0;
        state.game_over = false;
        state.paused = false;
        state.accumulator = 0.0f;
        state.step_time = config.base_speed_ms / 1000.0f;
        state.food_pulse = 0.0f;
        state.food = SnakeSegment(-1, -1);
        spawn_food();
    }
    
    void update(float dt) {
        if (state.game_over || state.paused) return;
        
        state.accumulator += dt;
        state.food_pulse += dt * 3.0f;
        
        while (state.accumulator >= state.step_time) {
            state.accumulator -= state.step_time;
            step();
        }
    }
    
    void set_direction(SnakeDirection dir) {
        bool opposite = false;
        switch (state.direction) {
            case SnakeDirection::UP:    opposite = (dir == SnakeDirection::DOWN); break;
            case SnakeDirection::DOWN:  opposite = (dir == SnakeDirection::UP); break;
            case SnakeDirection::LEFT:  opposite = (dir == SnakeDirection::RIGHT); break;
            case SnakeDirection::RIGHT: opposite = (dir == SnakeDirection::LEFT); break;
        }
        if (!opposite) {
            state.next_direction = dir;
        }
    }
    
    void toggle_pause() {
        if (!state.game_over) state.paused = !state.paused;
    }
    
    int get_grid_width() const { return config.grid_width; }
    int get_grid_height() const { return config.grid_height; }
    float get_cell_size() const { return config.cell_size; }
    const State& get_state() const { return state; }
    State& get_state() { return state; }
    
    void save_high_score() {
        if (state.score > state.high_score) {
            state.high_score = state.score;
        }
    }
    
private:
    void load_high_score() {
        FILE* f = fopen(get_save_path().c_str(), "r");
        if (f) {
            int hs = 0;
            if (fscanf(f, "%d", &hs) == 1) {
                state.high_score = hs;
            }
            fclose(f);
        }
    }
    
    void step() {
        state.direction = state.next_direction;
        
        SnakeSegment head = state.body.front();
        SnakeSegment new_head = head;
        switch (state.direction) {
            case SnakeDirection::UP:    new_head.y--; break;
            case SnakeDirection::DOWN:  new_head.y++; break;
            case SnakeDirection::LEFT:  new_head.x--; break;
            case SnakeDirection::RIGHT: new_head.x++; break;
        }
        
        // Wall collision
        if (new_head.x < 0 || new_head.x >= config.grid_width ||
            new_head.y < 0 || new_head.y >= config.grid_height) {
            game_over();
            return;
        }
        
        // Self collision
        for (const auto& seg : state.body) {
            if (seg == new_head) {
                game_over();
                return;
            }
        }
        
        // Move snake
        state.body.insert(state.body.begin(), new_head);
        
        // Food collision
        if (new_head == state.food) {
            state.score += 10;
            if (state.score % 50 == 0 && state.step_time > 0.05f) {
                state.step_time *= 0.9f;
            }
            spawn_food();
        } else {
            state.body.pop_back();
        }
    }
    
    void spawn_food() {
        std::uniform_int_distribution<int> dist_x(0, config.grid_width - 1);
        std::uniform_int_distribution<int> dist_y(0, config.grid_height - 1);
        
        SnakeSegment new_food;
        bool valid = false;
        for (int attempts = 0; attempts < 100 && !valid; ++attempts) {
            new_food = SnakeSegment(dist_x(rng), dist_y(rng));
            valid = true;
            for (const auto& seg : state.body) {
                if (seg == new_food) {
                    valid = false;
                    break;
                }
            }
        }
        state.food = new_food;
        state.food_pulse = 0.0f;
    }
    
    void game_over() {
        state.game_over = true;
        save_high_score();
        save_to_file();
    }
    
    void save_to_file() {
        FILE* f = fopen(get_save_path().c_str(), "w");
        if (f) {
            fprintf(f, "%d", state.high_score);
            fclose(f);
        }
    }
    
    std::string get_save_path() const {
        #ifdef _WIN32
        char* appdata = nullptr;
        size_t len = 0;
        _dupenv_s(&appdata, &len, "APPDATA");
        std::string path = appdata ? std::string(appdata) + "\\GuessingGameHub\\snake_highscore.txt" : "snake_highscore.txt";
        free(appdata);
        #elif __APPLE__
        const char* home = getenv("HOME");
        std::string path = home ? std::string(home) + "/Library/Application Support/GuessingGameHub/snake_highscore.txt" : "snake_highscore.txt";
        #else
        const char* home = getenv("HOME");
        std::string path = home ? std::string(home) + "/.config/GuessingGameHub/snake_highscore.txt" : "snake_highscore.txt";
        #endif
        return path;
    }
};