// Guessing Game GUI v2.0 - Enhanced with animations, particles, flip-card, larger UI
// Cross-platform C++ with Dear ImGui + SDL2
// Build: mkdir build && cd build && cmake .. && make

#include <SDL.h>
#include <SDL_render.h>
#include <imgui.h>
#include <backends/imgui_impl_sdl2.h>
#include <backends/imgui_impl_sdlrenderer2.h>

#include <random>
#include <string>
#include <vector>
#include <algorithm>
#include <cmath>
#include <fstream>
#include <cstdio>
#include <sys/stat.h>
#include <sys/types.h>

#include "snake_game.h"
#include "animation.h"

// ============================================================================
// GAME STATE - Guessing Game
// ============================================================================
struct GuessingGameState {
    int min_range = 1;
    int max_range = 100;
    int secret_number = 0;
    int guess = 0;
    int attempts = 0;
    bool game_started = false;
    bool game_won = false;
    bool show_win_animation = false;
    float win_anim_timer = 0.0f;
    std::string message = "Welcome! Set range and click 'Start Game'";
    std::vector<int> guess_history;
    
    std::mt19937 rng{std::random_device{}()};
    
    void start_game() {
        std::uniform_int_distribution<int> dist(min_range, max_range);
        secret_number = dist(rng);
        guess = 0;
        attempts = 0;
        game_started = true;
        game_won = false;
        show_win_animation = false;
        win_anim_timer = 0.0f;
        guess_history.clear();
        message = "Game started! Make your first guess.";
    }
    
    void make_guess() {
        if (!game_started || game_won) return;
        if (guess < min_range || guess > max_range) {
            message = "Guess must be between " + std::to_string(min_range) + " and " + std::to_string(max_range) + "!";
            return;
        }
        
        attempts++;
        guess_history.push_back(guess);
        
        if (guess == secret_number) {
            game_won = true;
            show_win_animation = true;
            win_anim_timer = 0.0f;
            message = "You won! The number was " + std::to_string(secret_number) + 
                      " in " + std::to_string(attempts) + " attempts!";
        } else if (guess < secret_number) {
            message = "Too low! Try higher.";
        } else {
            message = "Too high! Try lower.";
        }
    }
    
    void reset() {
        game_started = false;
        game_won = false;
        show_win_animation = false;
        win_anim_timer = 0.0f;
        guess = 0;
        attempts = 0;
        secret_number = 0;
        guess_history.clear();
        message = "Welcome! Set range and click 'Start Game'";
    }
    
    void update_win_animation(float dt) {
        if (show_win_animation) {
            win_anim_timer += dt;
            if (win_anim_timer > 3.0f) {
                show_win_animation = false;
            }
        }
    }
};

// ============================================================================
// APP STATE - Window, renderer, shared resources
// ============================================================================
struct AppState {
    SDL_Window* window = nullptr;
    SDL_Renderer* renderer = nullptr;
    int window_width = 1280;
    int window_height = 720;
    float dpi_scale = 1.0f;
    float ui_scale = 1.5f;  // Larger UI scale
    bool renderer_dirty = false;
    uint64_t last_frame_time = 0;
    float delta_time = 0.016f;
    
    // Shared systems
    ParticleSystem particles;
    FlipAnimation flip_anim;
    
    // Game instances
    GuessingGameState guessing_game;
    SnakeGame snake_game;
    
    // UI state
    enum class CurrentGame { GUESSING, SNAKE };
    CurrentGame current_game = CurrentGame::GUESSING;
    bool show_settings = false;
    
    // Persistence
    std::string config_path;
};

// ============================================================================
// UTILITIES
// ============================================================================
void ensure_dir_exists(const std::string& path) {
    #ifdef _WIN32
    _mkdir(path.c_str());
    #else
    mkdir(path.c_str(), 0755);
    #endif
}

std::string get_config_dir() {
    #ifdef _WIN32
    char* appdata = nullptr; size_t len = 0;
    _dupenv_s(&appdata, &len, "APPDATA");
    std::string path = appdata ? std::string(appdata) + "\\GuessingGameHub" : "GuessingGameHub";
    free(appdata);
    #elif __APPLE__
    const char* home = getenv("HOME");
    std::string path = home ? std::string(home) + "/Library/Application Support/GuessingGameHub" : "GuessingGameHub";
    #else
    const char* home = getenv("HOME");
    std::string path = home ? std::string(home) + "/.config/GuessingGameHub" : "GuessingGameHub";
    #endif
    ensure_dir_exists(path);
    return path;
}

void save_config(AppState& app) {
    std::string path = get_config_dir() + "/config.json";
    std::ofstream f(path);
    if (f) {
        f << "{\n";
        f << "  \"ui_scale\": " << app.ui_scale << ",\n";
        f << "  \"high_score_snake\": " << app.snake_game.get_state().high_score << "\n";
        f << "}\n";
    }
}

void load_config(AppState& app) {
    std::string path = get_config_dir() + "/config.json";
    std::ifstream f(path);
    if (f) {
        std::string content((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
        size_t pos = content.find("ui_scale");
        if (pos != std::string::npos) {
            pos = content.find(":", pos);
            if (pos != std::string::npos) {
                float val = std::stof(content.substr(pos + 1));
                if (val >= 1.0f && val <= 2.5f) app.ui_scale = val;
            }
        }
    }
}

// ============================================================================
// STYLING - Enhanced modern theme with larger elements
// ============================================================================
void apply_enhanced_style(float dpi_scale, float ui_scale) {
    float s = dpi_scale * ui_scale;
    ImGui::StyleColorsDark();
    ImGuiStyle& style = ImGui::GetStyle();
    
    // Rounded everything
    style.WindowRounding = 16.0f * s;
    style.ChildRounding = 12.0f * s;
    style.FrameRounding = 10.0f * s;
    style.GrabRounding = 10.0f * s;
    style.PopupRounding = 12.0f * s;
    style.ScrollbarRounding = 10.0f * s;
    style.TabRounding = 10.0f * s;
    
    // Generous spacing
    style.WindowPadding = ImVec2(24 * s, 24 * s);
    style.FramePadding = ImVec2(14 * s, 10 * s);
    style.ItemSpacing = ImVec2(14 * s, 12 * s);
    style.ItemInnerSpacing = ImVec2(10 * s, 8 * s);
    style.IndentSpacing = 28 * s;
    style.ScrollbarSize = 12 * s;
    style.GrabMinSize = 18 * s;
    
    // Enhanced colors - richer palette
    ImVec4* c = style.Colors;
    c[ImGuiCol_WindowBg]           = ImVec4(0.05f, 0.06f, 0.09f, 1.00f);
    c[ImGuiCol_ChildBg]            = ImVec4(0.08f, 0.09f, 0.12f, 1.00f);
    c[ImGuiCol_PopupBg]            = ImVec4(0.08f, 0.09f, 0.12f, 0.98f);
    c[ImGuiCol_Border]             = ImVec4(0.20f, 0.22f, 0.28f, 1.00f);
    c[ImGuiCol_BorderShadow]       = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    
    c[ImGuiCol_FrameBg]            = ImVec4(0.10f, 0.12f, 0.16f, 1.00f);
    c[ImGuiCol_FrameBgHovered]     = ImVec4(0.14f, 0.16f, 0.21f, 1.00f);
    c[ImGuiCol_FrameBgActive]      = ImVec4(0.18f, 0.20f, 0.26f, 1.00f);
    
    c[ImGuiCol_TitleBg]            = ImVec4(0.07f, 0.08f, 0.11f, 1.00f);
    c[ImGuiCol_TitleBgActive]      = ImVec4(0.10f, 0.12f, 0.16f, 1.00f);
    c[ImGuiCol_TitleBgCollapsed]   = ImVec4(0.05f, 0.06f, 0.09f, 0.90f);
    
    // Primary accent - vibrant blue
    ImVec4 accent = ImVec4(0.20f, 0.50f, 1.00f, 1.00f);
    ImVec4 accent_hover = ImVec4(0.30f, 0.60f, 1.00f, 1.00f);
    ImVec4 accent_active = ImVec4(0.15f, 0.40f, 0.90f, 1.00f);
    c[ImGuiCol_Button]             = accent;
    c[ImGuiCol_ButtonHovered]      = accent_hover;
    c[ImGuiCol_ButtonActive]       = accent_active;
    
    c[ImGuiCol_Header]             = ImVec4(accent.x, accent.y, accent.z, 0.30f);
    c[ImGuiCol_HeaderHovered]      = ImVec4(accent.x, accent.y, accent.z, 0.50f);
    c[ImGuiCol_HeaderActive]       = ImVec4(accent.x, accent.y, accent.z, 0.70f);
    
    c[ImGuiCol_Separator]          = ImVec4(0.20f, 0.22f, 0.28f, 1.00f);
    c[ImGuiCol_SeparatorHovered]   = ImVec4(accent.x, accent.y, accent.z, 0.60f);
    c[ImGuiCol_SeparatorActive]    = ImVec4(accent.x, accent.y, accent.z, 0.80f);
    
    c[ImGuiCol_SliderGrab]         = ImVec4(0.30f, 0.65f, 1.00f, 1.00f);
    c[ImGuiCol_SliderGrabActive]   = ImVec4(0.40f, 0.75f, 1.00f, 1.00f);
    
    c[ImGuiCol_CheckMark]          = ImVec4(0.40f, 0.75f, 1.00f, 1.00f);
    c[ImGuiCol_Text]               = ImVec4(0.95f, 0.96f, 0.98f, 1.00f);
    c[ImGuiCol_TextDisabled]       = ImVec4(0.55f, 0.60f, 0.68f, 1.00f);
    
    c[ImGuiCol_ScrollbarBg]        = ImVec4(0.05f, 0.06f, 0.09f, 1.00f);
    c[ImGuiCol_ScrollbarGrab]      = ImVec4(0.28f, 0.31f, 0.38f, 1.00f);
    c[ImGuiCol_ScrollbarGrabHovered]= ImVec4(0.38f, 0.41f, 0.48f, 1.00f);
    c[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.48f, 0.51f, 0.58f, 1.00f);
    
    c[ImGuiCol_Tab]                = ImVec4(0.10f, 0.12f, 0.16f, 1.00f);
    c[ImGuiCol_TabHovered]         = ImVec4(accent.x, accent.y, accent.z, 0.50f);
    c[ImGuiCol_TabActive]          = ImVec4(accent.x, accent.y, accent.z, 0.70f);
    c[ImGuiCol_TabUnfocused]       = ImVec4(0.07f, 0.08f, 0.11f, 1.00f);
    c[ImGuiCol_TabUnfocusedActive] = ImVec4(0.10f, 0.12f, 0.16f, 1.00f);
    
    c[ImGuiCol_NavHighlight]       = ImVec4(accent.x, accent.y, accent.z, 0.80f);
    c[ImGuiCol_NavWindowingHighlight] = ImVec4(1.00f, 1.00f, 1.00f, 0.70f);
    c[ImGuiCol_NavWindowingDimBg]  = ImVec4(0.00f, 0.00f, 0.00f, 0.20f);
    c[ImGuiCol_ModalWindowDimBg]   = ImVec4(0.00f, 0.00f, 0.00f, 0.50f);
    
    style.AntiAliasedLines = true;
    style.AntiAliasedLinesUseTex = true;
    style.AntiAliasedFill = true;
    style.CurveTessellationTol = 1.25f;
}

// ============================================================================
// RENDERER MANAGEMENT
// ============================================================================
void recreate_renderer(AppState& app) {
    if (app.renderer) {
        SDL_DestroyRenderer(app.renderer);
        app.renderer = nullptr;
    }
    app.renderer = SDL_CreateRenderer(app.window, -1,
        SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);
    if (!app.renderer) {
        SDL_Log("Failed to recreate renderer: %s", SDL_GetError());
        return;
    }
    SDL_RenderSetLogicalSize(app.renderer, app.window_width, app.window_height);
    SDL_RenderSetIntegerScale(app.renderer, SDL_TRUE);
    ImGui_ImplSDLRenderer2_Shutdown();
    ImGui_ImplSDLRenderer2_Init(app.renderer);
    app.renderer_dirty = false;
}

void handle_window_event(AppState& app, const SDL_Event& event) {
    if (event.type == SDL_WINDOWEVENT) {
        switch (event.window.event) {
            case SDL_WINDOWEVENT_SIZE_CHANGED:
            case SDL_WINDOWEVENT_RESIZED: {
                app.window_width = event.window.data1;
                app.window_height = event.window.data2;
                app.renderer_dirty = true;
                break;
            }
            case SDL_WINDOWEVENT_DISPLAY_CHANGED: {
                int display_index = SDL_GetWindowDisplayIndex(app.window);
                if (display_index >= 0) {
                    float ddpi, hdpi, vdpi;
                    if (SDL_GetDisplayDPI(display_index, &ddpi, &hdpi, &vdpi) == 0) {
                        app.dpi_scale = hdpi / 96.0f;
                        if (app.dpi_scale < 1.0f) app.dpi_scale = 1.0f;
                        if (app.dpi_scale > 3.0f) app.dpi_scale = 3.0f;
                    }
                }
                apply_enhanced_style(app.dpi_scale, app.ui_scale);
                ImGui::GetIO().FontGlobalScale = app.dpi_scale * app.ui_scale;
                app.renderer_dirty = true;
                break;
            }
        }
    }
}

// ============================================================================
// RENDER HELPERS
// ============================================================================
void draw_background_grid(ImDrawList* dl, ImGuiViewport* vp, float scale) {
    ImU32 bg = IM_COL32(12, 15, 22, 255);
    dl->AddRectFilled(vp->WorkPos, 
        ImVec2(vp->WorkPos.x + vp->WorkSize.x, vp->WorkPos.y + vp->WorkSize.y), bg);
    
    ImU32 grid = IM_COL32(28, 32, 42, 255);
    float gs = 50.0f * scale;
    for (float x = vp->WorkPos.x; x < vp->WorkPos.x + vp->WorkSize.x; x += gs) {
        dl->AddLine(ImVec2(x, vp->WorkPos.y), ImVec2(x, vp->WorkPos.y + vp->WorkSize.y), grid, 1.0f);
    }
    for (float y = vp->WorkPos.y; y < vp->WorkPos.y + vp->WorkSize.y; y += gs) {
        dl->AddLine(ImVec2(vp->WorkPos.x, y), ImVec2(vp->WorkPos.x + vp->WorkSize.x, y), grid, 1.0f);
    }
}

// ============================================================================
// GUESSING GAME UI
// ============================================================================
void render_guessing_game(AppState& app, ImGuiViewport* vp, float s) {
    float win_w = 580.0f * s;
    float win_h = 680.0f * s;
    float cw = win_w - 48.0f * s;  // content width
    
    ImGui::SetNextWindowPos(ImVec2(
        vp->WorkPos.x + (vp->WorkSize.x - win_w) * 0.5f,
        vp->WorkPos.y + (vp->WorkSize.y - win_h) * 0.5f
    ), ImGuiCond_Always);
    ImGui::SetNextWindowSize(ImVec2(win_w, win_h), ImGuiCond_Always);
    
    ImGui::Begin("##GuessingGame", nullptr, 
        ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove |
        ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoScrollbar);
    
    auto& g = app.guessing_game;
    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 win_pos = ImGui::GetWindowPos();
    ImVec2 win_size = ImGui::GetWindowSize();
    
    // Header with flip button
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(12 * s, 8 * s));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(10 * s, 8 * s));
    
    // Game title
    ImGui::SetCursorPosX((win_size.x - ImGui::CalcTextSize("Guessing Game").x) * 0.5f);
    ImGui::TextColored(ImVec4(0.95f, 0.96f, 0.98f, 1.0f), "Guessing Game");
    
    ImGui::SetCursorPosX((win_size.x - ImGui::CalcTextSize("Guess the secret number").x) * 0.5f);
    ImGui::TextColored(ImVec4(0.60f, 0.65f, 0.72f, 1.00f), "Guess the secret number");
    
    ImGui::Spacing();
    ImGui::Separator();
    ImGui::Spacing();
    
    if (!g.game_started) {
        // SETUP PHASE
        
        // Range label
        ImGui::Text("Range");
        ImGui::Spacing();
        
        // Min/Max inputs - larger
        float iw = (cw - 16.0f * s) * 0.5f;
        ImGui::PushItemWidth(iw);
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(14 * s, 12 * s));
        
        // Use local buffers for input
        static char min_buf[32] = "1";
        static char max_buf[32] = "100";
        ImGui::InputText("##Min", min_buf, 32, ImGuiInputTextFlags_CharsDecimal);
        ImGui::SameLine(0, 16 * s);
        ImGui::InputText("##Max", max_buf, 32, ImGuiInputTextFlags_CharsDecimal);
        ImGui::PopItemWidth();
        ImGui::PopStyleVar();
        
        ImGui::Spacing();
        ImGui::Spacing();
        
        // Start button - BIG
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(20 * s, 16 * s));
        if (ImGui::Button("Start Game", ImVec2(-1, 60 * s))) {
            g.min_range = std::max(1, std::atoi(min_buf));
            g.max_range = std::max(g.min_range + 1, std::atoi(max_buf));
            snprintf(min_buf, 32, "%d", g.min_range);
            snprintf(max_buf, 32, "%d", g.max_range);
            g.start_game();
        }
        ImGui::PopStyleVar();
        
    } else if (!g.game_won) {
        // PLAYING PHASE
        
        // Info bar
        ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.60f, 0.65f, 0.72f, 1.00f));
        ImGui::Text("Range: %d - %d    Attempts: %d", g.min_range, g.max_range, g.attempts);
        ImGui::PopStyleColor();
        
        ImGui::Spacing();
        ImGui::Separator();
        ImGui::Spacing();
        
        // Message with animation
        ImVec4 msg_col = ImVec4(0.92f, 0.93f, 0.95f, 1.00f);
        if (g.message.find("low") != std::string::npos) msg_col = ImVec4(1.00f, 0.75f, 0.30f, 1.00f);
        else if (g.message.find("high") != std::string::npos) msg_col = ImVec4(1.00f, 0.45f, 0.45f, 1.00f);
        else if (g.message.find("must be") != std::string::npos) msg_col = ImVec4(1.00f, 0.35f, 0.35f, 1.00f);
        
        ImGui::PushStyleColor(ImGuiCol_Text, msg_col);
        ImGui::PushTextWrapPos(win_w - 60 * s);
        ImGui::SetCursorPosX((win_size.x - ImGui::CalcTextSize(g.message.c_str()).x) * 0.5f);
        ImGui::TextWrapped("%s", g.message.c_str());
        ImGui::PopTextWrapPos();
        ImGui::PopStyleColor();
        
        ImGui::Spacing();
        ImGui::Separator();
        ImGui::Spacing();
        
        // Guess input - LARGE
        ImGui::Text("Your Guess");
        ImGui::PushItemWidth(-1);
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(16 * s, 14 * s));
        static char guess_buf[32] = "";
        bool enter = ImGui::InputText("##Guess", guess_buf, 32, 
            ImGuiInputTextFlags_CharsDecimal | ImGuiInputTextFlags_EnterReturnsTrue);
        ImGui::PopItemWidth();
        ImGui::PopStyleVar();
        
        ImGui::Spacing();
        
        // Big Guess button
        float bw = (cw - 16.0f * s) * 0.5f;
        if (ImGui::Button("Guess", ImVec2(bw, 56 * s)) || enter) {
            g.guess = std::atoi(guess_buf);
            g.make_guess();
            guess_buf[0] = '\0';
        }
        ImGui::SameLine(0, 16 * s);
        if (ImGui::Button("Clear", ImVec2(bw, 56 * s))) {
            guess_buf[0] = '\0';
        }
        
        ImGui::Spacing();
        ImGui::Spacing();
        
        // Quick picks - larger buttons
        ImGui::Text("Quick Picks");
        ImGui::Spacing();
        
        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.12f, 0.14f, 0.18f, 1.00f));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.18f, 0.20f, 0.26f, 1.00f));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.22f, 0.24f, 0.30f, 1.00f));
        
        float qp_w = (cw - 32.0f * s) * 0.2f;
        int mid = (g.min_range + g.max_range) / 2;
        int q1 = (g.min_range + mid) / 2;
        int q3 = (mid + g.max_range) / 2;
        
        auto qp_btn = [&](const char* label, int val) {
            if (ImGui::Button(label, ImVec2(qp_w, 44 * s))) { g.guess = val; g.make_guess(); }
        };
        
        qp_btn("Min", g.min_range); ImGui::SameLine(0, 8 * s);
        qp_btn("25%", q1); ImGui::SameLine(0, 8 * s);
        qp_btn("50%", mid); ImGui::SameLine(0, 8 * s);
        qp_btn("75%", q3); ImGui::SameLine(0, 8 * s);
        qp_btn("Max", g.max_range);
        
        ImGui::PopStyleColor(3);
        
        // History
        if (!g.guess_history.empty()) {
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.60f, 0.65f, 0.72f, 1.00f));
            ImGui::Text("History (%zu)", g.guess_history.size());
            ImGui::PopStyleColor();
            
            ImGui::BeginChild("Hist", ImVec2(0, 180 * s), true,
                ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_HorizontalScrollbar);
            
            for (int i = (int)g.guess_history.size() - 1; i >= 0; --i) {
                int val = g.guess_history[i];
                ImVec4 ec = ImVec4(0.75f, 0.78f, 0.82f, 1.00f);
                const char* ind = "";
                if (val < g.secret_number) { ec = ImVec4(1.00f, 0.75f, 0.30f, 1.00f); ind = " ^"; }
                else if (val > g.secret_number) { ec = ImVec4(1.00f, 0.45f, 0.45f, 1.00f); ind = " v"; }
                else { ec = ImVec4(0.40f, 0.85f, 0.40f, 1.00f); ind = " *"; }
                
                ImGui::PushStyleColor(ImGuiCol_Text, ec);
                ImGui::Text("#%-2zu  %d%s", g.guess_history.size() - i, val, ind);
                ImGui::PopStyleColor();
            }
            ImGui::EndChild();
        }
        
    } else {
        // WON STATE - with celebration
        ImGui::Spacing();
        ImGui::Spacing();
        
        // Big win message
        ImGui::SetCursorPosX((win_size.x - ImGui::CalcTextSize("YOU WON!").x) * 0.5f);
        ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.40f, 0.95f, 0.40f, 1.00f));
        ImGui::Text("YOU WON!");
        ImGui::PopStyleColor();
        
        ImGui::Spacing();
        
        ImGui::SetCursorPosX((win_size.x - ImGui::CalcTextSize("The number was").x) * 0.5f);
        ImGui::TextColored(ImVec4(0.80f, 0.85f, 0.90f, 1.00f), "The number was %d", g.secret_number);
        
        ImGui::SetCursorPosX((win_size.x - ImGui::CalcTextSize("Guessed in X attempts!").x) * 0.5f);
        ImGui::TextColored(ImVec4(0.80f, 0.85f, 0.90f, 1.00f), "Guessed in %d attempt%s!", g.attempts, g.attempts == 1 ? "" : "s");
        
        ImGui::Spacing();
        ImGui::Spacing();
        ImGui::Separator();
        ImGui::Spacing();
        ImGui::Spacing();
        
        // Play again - BIG
        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.18f, 0.65f, 0.30f, 1.00f));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.25f, 0.75f, 0.35f, 1.00f));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.14f, 0.50f, 0.25f, 1.00f));
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(20 * s, 16 * s));
        if (ImGui::Button("Play Again", ImVec2(-1, 60 * s))) {
            g.reset();
        }
        ImGui::PopStyleVar();
        ImGui::PopStyleColor(3);
        
        ImGui::Spacing();
        
        // New range button
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(16 * s, 10 * s));
        if (ImGui::Button("New Range", ImVec2(-1, 48 * s))) {
            g.reset();
        }
        ImGui::PopStyleVar();
    }
    
    // Flip button at bottom
    ImGui::Spacing();
    ImGui::Separator();
    ImGui::Spacing();
    
    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.15f, 0.18f, 0.23f, 1.00f));
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.20f, 0.23f, 0.29f, 1.00f));
    ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.25f, 0.28f, 0.35f, 1.00f));
    if (ImGui::Button("Flip to Snake Game", ImVec2(-1, 44 * s))) {
        app.flip_anim.request_flip(true);
        app.current_game = AppState::CurrentGame::SNAKE;
    }
    ImGui::PopStyleColor(3);
    
    ImGui::PopStyleVar(2);
    ImGui::End();
}

// ============================================================================
// SNAKE GAME UI
// ============================================================================
void render_snake_game(AppState& app, ImGuiViewport* vp, float s) {
    // Calculate grid dimensions first
    float cell = app.snake_game.get_cell_size() * s;
    int gw = app.snake_game.get_grid_width();
    int gh = app.snake_game.get_grid_height();
    float grid_w = gw * cell;
    float grid_h = gh * cell;
    
    // Window size based on grid + UI padding
    float ui_top = 140.0f * s;  // Space for header + score
    float ui_bottom = 140.0f * s; // Space for controls + buttons
    float win_w = std::max(580.0f * s, grid_w + 48.0f * s);
    float win_h = std::max(680.0f * s, grid_h + ui_top + ui_bottom);
    
    ImGui::SetNextWindowPos(ImVec2(
        vp->WorkPos.x + (vp->WorkSize.x - win_w) * 0.5f,
        vp->WorkPos.y + (vp->WorkSize.y - win_h) * 0.5f
    ), ImGuiCond_Always);
    ImGui::SetNextWindowSize(ImVec2(win_w, win_h), ImGuiCond_Always);
    
    ImGui::Begin("##SnakeGame", nullptr,
        ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove |
        ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoScrollbar);
    
    auto& snake = app.snake_game;
    auto& state = snake.get_state();
    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 win_pos = ImGui::GetWindowPos();
    ImVec2 win_size = ImGui::GetWindowSize();
    
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(12 * s, 8 * s));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(10 * s, 8 * s));
    
    // Header
    ImGui::SetCursorPosX((win_size.x - ImGui::CalcTextSize("Snake Game").x) * 0.5f);
    ImGui::TextColored(ImVec4(0.95f, 0.96f, 0.98f, 1.0f), "Snake Game");
    
    // Score display
    char score_text[64];
    snprintf(score_text, 64, "Score: %d   Best: %d", state.score, state.high_score);
    ImGui::SetCursorPosX((win_size.x - ImGui::CalcTextSize(score_text).x) * 0.5f);
    ImGui::TextColored(ImVec4(0.60f, 0.65f, 0.72f, 1.00f), "%s", score_text);
    
    ImGui::Spacing();
    ImGui::Separator();
    ImGui::Spacing();
    
    // Game grid area - centered in window
    float grid_x = win_pos.x + (win_size.x - grid_w) * 0.5f;
    float grid_y = win_pos.y + 140.0f * s;
    
    // Draw grid background
    ImU32 grid_bg = IM_COL32(10, 12, 16, 255);
    dl->AddRectFilled(ImVec2(grid_x, grid_y), ImVec2(grid_x + grid_w, grid_y + grid_h), grid_bg, 8 * s);
    
    // Grid lines
    ImU32 grid_line = IM_COL32(25, 28, 35, 255);
    for (int x = 0; x <= gw; ++x) {
        float px = grid_x + x * cell;
        dl->AddLine(ImVec2(px, grid_y), ImVec2(px, grid_y + grid_h), grid_line, 1.0f);
    }
    for (int y = 0; y <= gh; ++y) {
        float py = grid_y + y * cell;
        dl->AddLine(ImVec2(grid_x, py), ImVec2(grid_x + grid_w, py), grid_line, 1.0f);
    }
    
    // Draw food with pulse animation
    if (state.food.x >= 0) {
        float fx = grid_x + state.food.x * cell + cell * 0.5f;
        float fy = grid_y + state.food.y * cell + cell * 0.5f;
        float pulse = 1.0f + 0.15f * sinf(state.food_pulse * 4.0f);
        float fr = (cell * 0.35f) * pulse;
        ImU32 food_col = IM_COL32(255, 80, 80, 255);
        dl->AddCircleFilled(ImVec2(fx, fy), fr, food_col, 12);
        // Inner glow
        dl->AddCircleFilled(ImVec2(fx, fy), fr * 0.5f, IM_COL32(255, 180, 180, 200), 12);
    }
    
    // Draw snake body
    for (size_t i = 0; i < state.body.size(); ++i) {
        const auto& seg = state.body[i];
        float sx = grid_x + seg.x * cell + 1;
        float sy = grid_y + seg.y * cell + 1;
        float sw = cell - 2;
        float sh = cell - 2;
        float rounding = 4.0f * s;
        
        ImU32 seg_col;
        if (i == 0) {
            // Head - brighter
            seg_col = IM_COL32(60, 220, 100, 255);
        } else {
            // Body - gradient
            float t = (float)i / (float)state.body.size();
            int g = 180 + (int)(40.0f * (1.0f - t));
            int b = 60 + (int)(40.0f * (1.0f - t));
            seg_col = IM_COL32(40, g, b, 255);
        }
        
        if (i == 0) rounding = 6.0f * s;
        dl->AddRectFilled(ImVec2(sx, sy), ImVec2(sx + sw, sy + sh), seg_col, rounding);
        
        // Eyes on head
        if (i == 0) {
            float eye_r = 3.0f * s;
            float eye_y = sy + sh * 0.35f;
            float eye_x1 = sx + sw * 0.3f;
            float eye_x2 = sx + sw * 0.7f;
            if (state.direction == SnakeDirection::LEFT) { eye_x1 = sx + sw * 0.2f; eye_x2 = sx + sw * 0.6f; }
            if (state.direction == SnakeDirection::RIGHT) { eye_x1 = sx + sw * 0.4f; eye_x2 = sx + sw * 0.8f; }
            if (state.direction == SnakeDirection::UP) { eye_y = sy + sh * 0.25f; }
            if (state.direction == SnakeDirection::DOWN) { eye_y = sy + sh * 0.75f; }
            dl->AddCircleFilled(ImVec2(eye_x1, eye_y), eye_r, IM_COL32(255,255,255,255), 8);
            dl->AddCircleFilled(ImVec2(eye_x2, eye_y), eye_r, IM_COL32(255,255,255,255), 8);
        }
    }
    
    // Game over overlay - centered on grid
    if (state.game_over) {
        ImVec2 center(grid_x + grid_w * 0.5f, grid_y + grid_h * 0.5f);
        // Semi-transparent overlay
        dl->AddRectFilled(ImVec2(grid_x, grid_y), ImVec2(grid_x + grid_w, grid_y + grid_h), 
            IM_COL32(0, 0, 0, 180), 8 * s);
        
        // Game over text
        ImGui::GetWindowDrawList()->AddText(
            ImVec2(center.x - ImGui::CalcTextSize("GAME OVER").x * 0.5f, center.y - 40 * s),
            IM_COL32(255, 80, 80, 255), "GAME OVER"
        );
        
        char final_score[64];
        snprintf(final_score, 64, "Final Score: %d", state.score);
        ImGui::GetWindowDrawList()->AddText(
            ImVec2(center.x - ImGui::CalcTextSize(final_score).x * 0.5f, center.y + 10 * s),
            IM_COL32(200, 200, 220, 255), "%s", final_score
        );
    } else if (state.paused) {
        ImVec2 center(grid_x + grid_w * 0.5f, grid_y + grid_h * 0.5f);
        dl->AddRectFilled(ImVec2(grid_x, grid_y), ImVec2(grid_x + grid_w, grid_y + grid_h), 
            IM_COL32(0, 0, 0, 120), 8 * s);
        ImGui::GetWindowDrawList()->AddText(
            ImVec2(center.x - ImGui::CalcTextSize("PAUSED").x * 0.5f, center.y),
            IM_COL32(255, 200, 80, 255), "PAUSED"
        );
    }
    
    // Reserve space for grid in layout
    ImGui::Dummy(ImVec2(grid_w, grid_h + 140.0f * s));
    
    ImGui::Spacing();
    ImGui::Spacing();
    ImGui::Separator();
    ImGui::Spacing();
    
    // Controls hint
    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.50f, 0.55f, 0.62f, 1.00f));
    ImGui::TextWrapped("Controls: WASD / Arrow Keys / Gamepad  |  Space: Pause  |  R: Restart");
    ImGui::PopStyleColor();
    
    ImGui::Spacing();
    ImGui::Separator();
    ImGui::Spacing();
    
    // Restart button
    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.18f, 0.55f, 0.30f, 1.00f));
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.25f, 0.65f, 0.35f, 1.00f));
    ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.14f, 0.45f, 0.25f, 1.00f));
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(20 * s, 12 * s));
    if (ImGui::Button(state.game_over ? "Restart" : "Pause", ImVec2(-1, 48 * s))) {
        if (state.game_over) snake.reset();
        else snake.toggle_pause();
    }
    ImGui::PopStyleVar();
    ImGui::PopStyleColor(3);
    
    ImGui::Spacing();
    
    // Flip back button
    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.15f, 0.18f, 0.23f, 1.00f));
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.20f, 0.23f, 0.29f, 1.00f));
    ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.25f, 0.28f, 0.35f, 1.00f));
    if (ImGui::Button("Flip to Guessing Game", ImVec2(-1, 44 * s))) {
        app.flip_anim.request_flip(false);
        app.current_game = AppState::CurrentGame::GUESSING;
    }
    ImGui::PopStyleColor(3);
    
    ImGui::PopStyleVar(2);
    ImGui::End();
}

// ============================================================================
// FLIP ANIMATION RENDERING
// ============================================================================
void render_flip_animation(AppState& app, ImGuiViewport* vp, float s) {
    if (app.flip_anim.state == FlipState::IDLE_FRONT || app.flip_anim.state == FlipState::IDLE_BACK) 
        return;
    
    ImDrawList* dl = ImGui::GetBackgroundDrawList();
    float progress = app.flip_anim.progress;
    ImVec2 center(vp->WorkPos.x + vp->WorkSize.x * 0.5f, vp->WorkPos.y + vp->WorkSize.y * 0.5f);
    
    // Flip progress bar at top
    float bar_w = 300.0f * s;
    float bar_h = 6.0f * s;
    ImVec2 bar_pos(center.x - bar_w * 0.5f, vp->WorkPos.y + 20.0f * s);
    
    dl->AddRectFilled(bar_pos, ImVec2(bar_pos.x + bar_w, bar_pos.y + bar_h), 
        IM_COL32(20, 24, 30, 255), 3.0f * s);
    dl->AddRectFilled(bar_pos, ImVec2(bar_pos.x + bar_w * progress, bar_pos.y + bar_h),
        IM_COL32(80, 160, 255, 255), 3.0f * s);
    
    // Game name transition
    const char* from = app.flip_anim.flip_to_back ? "Guessing Game" : "Snake Game";
    const char* to = app.flip_anim.flip_to_back ? "Snake Game" : "Guessing Game";
    
    float alpha_from = 1.0f, alpha_to = 0.0f;
    if (app.flip_anim.state == FlipState::FLIPPING_TO_BACK) {
        alpha_from = 1.0f - progress * 2.0f;
        alpha_to = progress * 2.0f - 1.0f;
    } else {
        alpha_from = progress * 2.0f - 1.0f;
        alpha_to = 1.0f - progress * 2.0f;
    }
    alpha_from = std::clamp(alpha_from, 0.0f, 1.0f);
    alpha_to = std::clamp(alpha_to, 0.0f, 1.0f);
    
    if (alpha_from > 0) {
        ImU32 col = IM_COL32(255, 255, 255, (int)(255.0f * alpha_from));
        dl->AddText(ImVec2(center.x - ImGui::CalcTextSize(from).x * 0.5f, center.y - 60.0f * s), col, from);
    }
    if (alpha_to > 0) {
        ImU32 col = IM_COL32(255, 255, 255, (int)(255.0f * alpha_to));
        dl->AddText(ImVec2(center.x - ImGui::CalcTextSize(to).x * 0.5f, center.y + 20.0f * s), col, to);
    }
}

// ============================================================================
// MAIN
// ============================================================================
int main(int argc, char* argv[]) {
    (void)argc; (void)argv;
    
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0) {
        SDL_Log("Failed to initialize SDL: %s", SDL_GetError());
        return 1;
    }
    
    #ifdef _WIN32
    SDL_SetHint(SDL_HINT_WINDOWS_DPI_SCALING, "1");
    SDL_SetHint(SDL_HINT_WINDOWS_DPI_AWARENESS, "permonitorv2");
    #endif
    
    AppState app;
    app.config_path = get_config_dir() + "/config.json";
    load_config(app);
    
    SDL_WindowFlags flags = (SDL_WindowFlags)(SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_HIDDEN);
    app.window = SDL_CreateWindow("Guessing Game Hub", 
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, flags);
    if (!app.window) { SDL_Log("Window failed: %s", SDL_GetError()); SDL_Quit(); return 1; }
    
    int dw, dh; SDL_GL_GetDrawableSize(app.window, &dw, &dh);
    app.dpi_scale = (float)dw / 1280.0f;
    
    app.renderer = SDL_CreateRenderer(app.window, -1,
        SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);
    if (!app.renderer) { SDL_Log("Renderer failed: %s", SDL_GetError()); SDL_DestroyWindow(app.window); SDL_Quit(); return 1; }
    
    SDL_RenderSetLogicalSize(app.renderer, app.window_width, app.window_height);
    SDL_RenderSetIntegerScale(app.renderer, SDL_TRUE);
    SDL_ShowWindow(app.window);
    
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard | ImGuiConfigFlags_NavEnableGamepad;
    io.ConfigWindowsMoveFromTitleBarOnly = true;
    
    apply_enhanced_style(app.dpi_scale, app.ui_scale);
    io.FontGlobalScale = app.dpi_scale * app.ui_scale;
    io.Fonts->AddFontDefault();
    
    ImGui_ImplSDL2_InitForSDLRenderer(app.window, app.renderer);
    ImGui_ImplSDLRenderer2_Init(app.renderer);
    
    app.last_frame_time = SDL_GetPerformanceCounter();
    
    bool done = false;
    while (!done) {
        // Delta time
        uint64_t now = SDL_GetPerformanceCounter();
        app.delta_time = (float)(now - app.last_frame_time) / SDL_GetPerformanceFrequency();
        app.last_frame_time = now;
        if (app.delta_time > 0.1f) app.delta_time = 0.1f;
        
        // Events
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            ImGui_ImplSDL2_ProcessEvent(&event);
            handle_window_event(app, event);
            
            if (event.type == SDL_QUIT) done = true;
            if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && 
                event.window.windowID == SDL_GetWindowID(app.window)) done = true;
            
            // Snake input
            if (event.type == SDL_KEYDOWN && app.current_game == AppState::CurrentGame::SNAKE) {
                auto& state = app.snake_game.get_state();
                if (!state.game_over && !state.paused) {
                    switch (event.key.keysym.sym) {
                        case SDLK_UP: case SDLK_w: app.snake_game.set_direction(SnakeDirection::UP); break;
                        case SDLK_DOWN: case SDLK_s: app.snake_game.set_direction(SnakeDirection::DOWN); break;
                        case SDLK_LEFT: case SDLK_a: app.snake_game.set_direction(SnakeDirection::LEFT); break;
                        case SDLK_RIGHT: case SDLK_d: app.snake_game.set_direction(SnakeDirection::RIGHT); break;
                        case SDLK_SPACE: app.snake_game.toggle_pause(); break;
                        case SDLK_r: app.snake_game.reset(); break;
                    }
                } else if (state.game_over && event.key.keysym.sym == SDLK_r) {
                    app.snake_game.reset();
                } else if (event.key.keysym.sym == SDLK_SPACE) {
                    app.snake_game.toggle_pause();
                }
            }
        }
        
        if (app.renderer_dirty) recreate_renderer(app);
        
        // Update game logic
        app.guessing_game.update_win_animation(app.delta_time);
        if (app.current_game == AppState::CurrentGame::SNAKE) {
            app.snake_game.update(app.delta_time);
        }
        app.flip_anim.update(app.delta_time);
        app.particles.update(app.delta_time);
        
        // Win particles
        if (app.guessing_game.show_win_animation && app.guessing_game.win_anim_timer < 0.1f) {
            ImGuiViewport* vp = ImGui::GetMainViewport();
            ImVec2 center(vp->WorkPos.x + vp->WorkSize.x * 0.5f, vp->WorkPos.y + vp->WorkSize.y * 0.5f);
            app.particles.emit_confetti(center, 80);
        }
        
        // New frame
        ImGui_ImplSDLRenderer2_NewFrame();
        ImGui_ImplSDL2_NewFrame();
        ImGui::NewFrame();
        
        // Background
        ImGuiViewport* vp = ImGui::GetMainViewport();
        ImGui::SetNextWindowPos(vp->WorkPos);
        ImGui::SetNextWindowSize(vp->WorkSize);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0,0));
        ImGui::Begin("##BG", nullptr, ImGuiWindowFlags_NoTitleBar|ImGuiWindowFlags_NoResize|ImGuiWindowFlags_NoMove|
            ImGuiWindowFlags_NoScrollbar|ImGuiWindowFlags_NoSavedSettings|ImGuiWindowFlags_NoBringToFrontOnFocus|
            ImGuiWindowFlags_NoNavFocus|ImGuiWindowFlags_NoBackground);
        draw_background_grid(ImGui::GetWindowDrawList(), vp, app.dpi_scale * app.ui_scale);
        ImGui::End();
        ImGui::PopStyleVar(3);
        
        // Render current game
        float total_scale = app.dpi_scale * app.ui_scale;
        if (app.current_game == AppState::CurrentGame::GUESSING) {
            render_guessing_game(app, vp, total_scale);
        } else {
            render_snake_game(app, vp, total_scale);
        }
        
        // Flip animation overlay
        render_flip_animation(app, vp, total_scale);
        
        // Particles
        app.particles.render(ImGui::GetBackgroundDrawList());
        
        // Settings window
        if (app.show_settings) {
            ImGui::SetNextWindowSize(ImVec2(400 * total_scale, 350 * total_scale), ImGuiCond_FirstUseEver);
            ImGui::Begin("Settings", &app.show_settings);
            ImGui::Text("UI Scale");
            ImGui::SliderFloat("##scale", &app.ui_scale, 1.0f, 2.5f, "%.1fx");
            ImGui::Spacing();
            if (ImGui::Button("Save & Close", ImVec2(-1, 40 * total_scale))) {
                save_config(app);
                apply_enhanced_style(app.dpi_scale, app.ui_scale);
                io.FontGlobalScale = app.dpi_scale * app.ui_scale;
                app.show_settings = false;
            }
            ImGui::End();
        }
        
        // Render
        ImGui::Render();
        SDL_SetRenderDrawColor(app.renderer, 12, 15, 22, 255);
        SDL_RenderClear(app.renderer);
        ImGui_ImplSDLRenderer2_RenderDrawData(ImGui::GetDrawData(), app.renderer);
        SDL_RenderPresent(app.renderer);
    }
    
    save_config(app);
    
    ImGui_ImplSDLRenderer2_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
    SDL_DestroyRenderer(app.renderer);
    SDL_DestroyWindow(app.window);
    SDL_Quit();
    return 0;
}