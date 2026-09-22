// Guessing Game GUI - Cross-platform C++ with Dear ImGui + SDL2
// Build: mkdir build && cd build && cmake .. && make
// Run: ./GuessingGame (Linux/macOS) or GuessingGame.exe (Windows)

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

struct GameState {
    int min_range = 1;
    int max_range = 100;
    int secret_number = 0;
    int guess = 0;
    int attempts = 0;
    bool game_started = false;
    bool game_won = false;
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
        guess = 0;
        attempts = 0;
        secret_number = 0;
        guess_history.clear();
        message = "Welcome! Set range and click 'Start Game'";
    }
};

struct AppState {
    SDL_Window* window = nullptr;
    SDL_Renderer* renderer = nullptr;
    int window_width = 1280;
    int window_height = 720;
    float dpi_scale = 1.0f;
    bool renderer_dirty = false;
};

void apply_modern_style(float dpi_scale) {
    ImGui::StyleColorsDark();
    ImGuiStyle& style = ImGui::GetStyle();
    
    // Modern spacing & rounding
    style.WindowRounding = 12.0f * dpi_scale;
    style.ChildRounding = 8.0f * dpi_scale;
    style.FrameRounding = 6.0f * dpi_scale;
    style.GrabRounding = 6.0f * dpi_scale;
    style.PopupRounding = 8.0f * dpi_scale;
    style.ScrollbarRounding = 6.0f * dpi_scale;
    style.TabRounding = 6.0f * dpi_scale;
    
    style.WindowPadding = ImVec2(16 * dpi_scale, 16 * dpi_scale);
    style.FramePadding = ImVec2(10 * dpi_scale, 8 * dpi_scale);
    style.ItemSpacing = ImVec2(10 * dpi_scale, 8 * dpi_scale);
    style.ItemInnerSpacing = ImVec2(8 * dpi_scale, 6 * dpi_scale);
    style.IndentSpacing = 20 * dpi_scale;
    style.ScrollbarSize = 10 * dpi_scale;
    style.GrabMinSize = 14 * dpi_scale;
    
    // Modern color palette - slate/blue theme
    ImVec4* colors = style.Colors;
    colors[ImGuiCol_WindowBg]           = ImVec4(0.06f, 0.07f, 0.10f, 1.00f);  // Deep slate
    colors[ImGuiCol_ChildBg]            = ImVec4(0.09f, 0.10f, 0.13f, 1.00f);
    colors[ImGuiCol_PopupBg]            = ImVec4(0.09f, 0.10f, 0.13f, 0.98f);
    colors[ImGuiCol_Border]             = ImVec4(0.18f, 0.20f, 0.25f, 1.00f);
    colors[ImGuiCol_BorderShadow]       = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    
    colors[ImGuiCol_FrameBg]            = ImVec4(0.12f, 0.14f, 0.18f, 1.00f);
    colors[ImGuiCol_FrameBgHovered]     = ImVec4(0.16f, 0.18f, 0.23f, 1.00f);
    colors[ImGuiCol_FrameBgActive]      = ImVec4(0.20f, 0.22f, 0.28f, 1.00f);
    
    colors[ImGuiCol_TitleBg]            = ImVec4(0.08f, 0.09f, 0.12f, 1.00f);
    colors[ImGuiCol_TitleBgActive]      = ImVec4(0.12f, 0.14f, 0.18f, 1.00f);
    colors[ImGuiCol_TitleBgCollapsed]   = ImVec4(0.06f, 0.07f, 0.10f, 0.90f);
    
    colors[ImGuiCol_Button]             = ImVec4(0.18f, 0.35f, 0.75f, 1.00f);  // Primary blue
    colors[ImGuiCol_ButtonHovered]      = ImVec4(0.25f, 0.45f, 0.85f, 1.00f);
    colors[ImGuiCol_ButtonActive]       = ImVec4(0.14f, 0.28f, 0.65f, 1.00f);
    
    colors[ImGuiCol_Header]             = ImVec4(0.18f, 0.35f, 0.75f, 0.35f);
    colors[ImGuiCol_HeaderHovered]      = ImVec4(0.18f, 0.35f, 0.75f, 0.55f);
    colors[ImGuiCol_HeaderActive]       = ImVec4(0.18f, 0.35f, 0.75f, 0.75f);
    
    colors[ImGuiCol_Separator]          = ImVec4(0.18f, 0.20f, 0.25f, 1.00f);
    colors[ImGuiCol_SeparatorHovered]   = ImVec4(0.18f, 0.35f, 0.75f, 0.60f);
    colors[ImGuiCol_SeparatorActive]    = ImVec4(0.18f, 0.35f, 0.75f, 0.80f);
    
    colors[ImGuiCol_SliderGrab]         = ImVec4(0.25f, 0.50f, 0.95f, 1.00f);
    colors[ImGuiCol_SliderGrabActive]   = ImVec4(0.35f, 0.60f, 1.00f, 1.00f);
    
    colors[ImGuiCol_CheckMark]          = ImVec4(0.35f, 0.60f, 1.00f, 1.00f);
    colors[ImGuiCol_Text]               = ImVec4(0.92f, 0.93f, 0.95f, 1.00f);
    colors[ImGuiCol_TextDisabled]       = ImVec4(0.50f, 0.55f, 0.62f, 1.00f);
    
    colors[ImGuiCol_ScrollbarBg]        = ImVec4(0.06f, 0.07f, 0.10f, 1.00f);
    colors[ImGuiCol_ScrollbarGrab]      = ImVec4(0.25f, 0.28f, 0.35f, 1.00f);
    colors[ImGuiCol_ScrollbarGrabHovered]= ImVec4(0.35f, 0.38f, 0.45f, 1.00f);
    colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.45f, 0.48f, 0.55f, 1.00f);
    
    colors[ImGuiCol_Tab]                = ImVec4(0.12f, 0.14f, 0.18f, 1.00f);
    colors[ImGuiCol_TabHovered]         = ImVec4(0.18f, 0.35f, 0.75f, 0.50f);
    colors[ImGuiCol_TabActive]          = ImVec4(0.18f, 0.35f, 0.75f, 0.70f);
    colors[ImGuiCol_TabUnfocused]       = ImVec4(0.08f, 0.09f, 0.12f, 1.00f);
    colors[ImGuiCol_TabUnfocusedActive] = ImVec4(0.12f, 0.14f, 0.18f, 1.00f);
    
    // Disable alpha blending for sharper text
    style.AntiAliasedLines = true;
    style.AntiAliasedLinesUseTex = true;
    style.AntiAliasedFill = true;
    style.CurveTessellationTol = 1.25f;
}

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
    
    // Set logical size for consistent rendering
    SDL_RenderSetLogicalSize(app.renderer, app.window_width, app.window_height);
    SDL_RenderSetIntegerScale(app.renderer, SDL_TRUE);
    
    // Reinitialize ImGui renderer backend
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
                // Display changed, might need DPI update
                int display_index = SDL_GetWindowDisplayIndex(app.window);
                if (display_index >= 0) {
                    float ddpi, hdpi, vdpi;
                    if (SDL_GetDisplayDPI(display_index, &ddpi, &hdpi, &vdpi) == 0) {
                        app.dpi_scale = hdpi / 96.0f; // 96 DPI = 1.0 scale
                        if (app.dpi_scale < 1.0f) app.dpi_scale = 1.0f;
                        if (app.dpi_scale > 3.0f) app.dpi_scale = 3.0f;
                    }
                }
                apply_modern_style(app.dpi_scale);
                ImGui::GetIO().FontGlobalScale = app.dpi_scale;
                app.renderer_dirty = true;
                break;
            }
            case SDL_WINDOWEVENT_CLOSE: {
                // Handled in main loop
                break;
            }
        }
    }
}

int main(int argc, char* argv[]) {
    (void)argc; (void)argv;
    
    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0) {
        SDL_Log("Failed to initialize SDL: %s", SDL_GetError());
        return 1;
    }
    
    // Enable high DPI awareness on Windows
    #ifdef _WIN32
    SDL_SetHint(SDL_HINT_WINDOWS_DPI_SCALING, "1");
    SDL_SetHint(SDL_HINT_WINDOWS_DPI_AWARENESS, "permonitorv2");
    #endif
    
    AppState app;
    
    // Create window with high DPI support
    SDL_WindowFlags window_flags = (SDL_WindowFlags)(SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_HIDDEN);
    app.window = SDL_CreateWindow(
        "Guessing Game",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        1280, 720,  // 720p default
        window_flags
    );
    
    if (!app.window) {
        SDL_Log("Failed to create window: %s", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    
    // Get actual drawable size for high DPI
    int drawable_w, drawable_h;
    SDL_GL_GetDrawableSize(app.window, &drawable_w, &drawable_h);
    app.dpi_scale = (float)drawable_w / (float)app.window_width;
    
    // Create renderer
    app.renderer = SDL_CreateRenderer(app.window, -1, 
        SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);
    
    if (!app.renderer) {
        SDL_Log("Failed to create renderer: %s", SDL_GetError());
        SDL_DestroyWindow(app.window);
        SDL_Quit();
        return 1;
    }
    
    // Set logical rendering size
    SDL_RenderSetLogicalSize(app.renderer, app.window_width, app.window_height);
    SDL_RenderSetIntegerScale(app.renderer, SDL_TRUE);
    
    // Show window after renderer is ready
    SDL_ShowWindow(app.window);
    
    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;
    io.ConfigWindowsMoveFromTitleBarOnly = true;
    
    // Apply modern style
    apply_modern_style(app.dpi_scale);
    io.FontGlobalScale = app.dpi_scale;
    
    // Load a better font
    io.Fonts->AddFontDefault();
    // Build font atlas with extra glyphs
    // io.Fonts->Build();  // Not needed with new SDL2 backend - handled automatically
    
    // Setup Platform/Renderer backends
    ImGui_ImplSDL2_InitForSDLRenderer(app.window, app.renderer);
    ImGui_ImplSDLRenderer2_Init(app.renderer);
    GameState game;
    char guess_buffer[32] = "";
    char min_buffer[32] = "1";
    char max_buffer[32] = "100";
    
    // Main loop
    bool done = false;
    while (!done) {
        // Handle events
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            ImGui_ImplSDL2_ProcessEvent(&event);
            handle_window_event(app, event);
            
            if (event.type == SDL_QUIT)
                done = true;
            if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(app.window))
                done = true;
        }
        
        // Recreate renderer if needed (after resize)
        if (app.renderer_dirty) {
            recreate_renderer(app);
        }
        
        // Start Dear ImGui frame
        ImGui_ImplSDLRenderer2_NewFrame();
        ImGui_ImplSDL2_NewFrame();
        ImGui::NewFrame();
        
        // Full-screen background window (no title bar, covers entire window)
        ImGuiViewport* viewport = ImGui::GetMainViewport();
        ImGui::SetNextWindowPos(viewport->WorkPos);
        ImGui::SetNextWindowSize(viewport->WorkSize);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0, 0));
        ImGui::Begin("##Background", nullptr, 
            ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | 
            ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoSavedSettings | 
            ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus |
            ImGuiWindowFlags_NoBackground);
        
        // Draw subtle background pattern
        ImDrawList* draw_list = ImGui::GetWindowDrawList();
        ImU32 bg_col = IM_COL32(15, 18, 25, 255);
        draw_list->AddRectFilled(viewport->WorkPos, 
            ImVec2(viewport->WorkPos.x + viewport->WorkSize.x, viewport->WorkPos.y + viewport->WorkSize.y), bg_col);
        
        // Subtle grid pattern
        ImU32 grid_col = IM_COL32(30, 35, 45, 255);
        float grid_size = 40.0f * app.dpi_scale;
        for (float x = viewport->WorkPos.x; x < viewport->WorkPos.x + viewport->WorkSize.x; x += grid_size) {
            draw_list->AddLine(ImVec2(x, viewport->WorkPos.y), 
                ImVec2(x, viewport->WorkPos.y + viewport->WorkSize.y), grid_col, 1.0f);
        }
        for (float y = viewport->WorkPos.y; y < viewport->WorkPos.y + viewport->WorkSize.y; y += grid_size) {
            draw_list->AddLine(ImVec2(viewport->WorkPos.x, y), 
                ImVec2(viewport->WorkPos.x + viewport->WorkSize.x, y), grid_col, 1.0f);
        }
        
        ImGui::End();
        ImGui::PopStyleVar(3);
        
        // Main game window - centered
        float win_w = 520.0f * app.dpi_scale;
        float win_h = 620.0f * app.dpi_scale;
        ImGui::SetNextWindowPos(ImVec2(
            viewport->WorkPos.x + (viewport->WorkSize.x - win_w) * 0.5f,
            viewport->WorkPos.y + (viewport->WorkSize.y - win_h) * 0.5f
        ), ImGuiCond_Always);
        ImGui::SetNextWindowSize(ImVec2(win_w, win_h), ImGuiCond_Always);
        
        ImGui::Begin("##GameWindow", nullptr, 
            ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove |
            ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoScrollbar);
        
        // Header bar
        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0,0,0,0));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.2f, 0.25f, 0.35f, 0.5f));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.2f, 0.25f, 0.35f, 0.8f));
        if (ImGui::Button("Guessing Game", ImVec2(-1, 44 * app.dpi_scale))) {}
        ImGui::PopStyleColor(3);
        
        ImGui::Separator();
        ImGui::Spacing();
        
        // Content width used in both phases
        float content_width = win_w - 32 * app.dpi_scale;
        
        if (!game.game_started) {
            // Setup phase - centered content
            
            ImGui::PushFont(io.Fonts->Fonts[0]);
            ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(10 * app.dpi_scale, 16 * app.dpi_scale));
            
            // Title
            ImGui::SetCursorPosX((win_w - ImGui::CalcTextSize("Guessing Game").x) * 0.5f);
            ImGui::TextColored(ImVec4(0.92f, 0.93f, 0.95f, 1.0f), "Guessing Game");
            
            ImGui::SetCursorPosX((win_w - ImGui::CalcTextSize("Set the range and start playing").x) * 0.5f);
            ImGui::TextColored(ImVec4(0.55f, 0.60f, 0.68f, 1.0f), "Set the range and start playing");
            
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            
            // Range inputs - side by side
            float input_w = (content_width - 12 * app.dpi_scale) * 0.5f;
            
            ImGui::Text("Range");
            ImGui::PushItemWidth(input_w);
            ImGui::InputText("##Min", min_buffer, 32, ImGuiInputTextFlags_CharsDecimal);
            ImGui::SameLine(0, 12 * app.dpi_scale);
            ImGui::InputText("##Max", max_buffer, 32, ImGuiInputTextFlags_CharsDecimal);
            ImGui::PopItemWidth();
            
            ImGui::Spacing();
            
            // Start button - full width
            if (ImGui::Button("Start Game", ImVec2(-1, 48 * app.dpi_scale))) {
                game.min_range = std::max(1, std::atoi(min_buffer));
                game.max_range = std::max(game.min_range + 1, std::atoi(max_buffer));
                snprintf(min_buffer, 32, "%d", game.min_range);
                snprintf(max_buffer, 32, "%d", game.max_range);
                game.start_game();
            }
            
            ImGui::PopStyleVar();
            ImGui::PopFont();
            
        } else {
            // Game phase
            ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(10 * app.dpi_scale, 12 * app.dpi_scale));
            
            // Range & attempts info
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.60f, 0.65f, 0.72f, 1.00f));
            ImGui::Text("Range: %d - %d   |   Attempts: %d", game.min_range, game.max_range, game.attempts);
            ImGui::PopStyleColor();
            
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            
            // Message display with color
            ImVec4 msg_color = ImVec4(0.92f, 0.93f, 0.95f, 1.00f);
            if (game.game_won) msg_color = ImVec4(0.40f, 0.85f, 0.40f, 1.00f);
            else if (game.message.find("low") != std::string::npos) msg_color = ImVec4(1.00f, 0.75f, 0.30f, 1.00f);
            else if (game.message.find("high") != std::string::npos) msg_color = ImVec4(1.00f, 0.45f, 0.45f, 1.00f);
            else if (game.message.find("must be") != std::string::npos) msg_color = ImVec4(1.00f, 0.35f, 0.35f, 1.00f);
            
            ImGui::PushStyleColor(ImGuiCol_Text, msg_color);
            ImGui::PushTextWrapPos(win_w - 48 * app.dpi_scale);
            ImGui::TextWrapped("%s", game.message.c_str());
            ImGui::PopTextWrapPos();
            ImGui::PopStyleColor();
            
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            
            if (!game.game_won) {
                // Input guess
                ImGui::Text("Your Guess");
                ImGui::PushItemWidth(-1);
                bool enter_pressed = ImGui::InputText("##Guess", guess_buffer, 32, 
                    ImGuiInputTextFlags_CharsDecimal | ImGuiInputTextFlags_EnterReturnsTrue);
                ImGui::PopItemWidth();
                
                ImGui::Spacing();
                
                // Guess button + quick picks in a row
                float btn_h = 44 * app.dpi_scale;
                float btn_w = (win_w - 48 * app.dpi_scale) * 0.33f;
                
                if (ImGui::Button("Guess", ImVec2(btn_w, btn_h))) {
                    game.guess = std::atoi(guess_buffer);
                    game.make_guess();
                    guess_buffer[0] = '\0';
                }
                ImGui::SameLine(0, 8 * app.dpi_scale);
                if (enter_pressed) {
                    game.guess = std::atoi(guess_buffer);
                    game.make_guess();
                    guess_buffer[0] = '\0';
                }
                
                ImGui::Spacing();
                
                // Quick picks
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.14f, 0.16f, 0.20f, 1.00f));
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.20f, 0.22f, 0.28f, 1.00f));
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.25f, 0.28f, 0.35f, 1.00f));
                
                ImGui::Text("Quick picks");
                float qp_w = (content_width - 32 * app.dpi_scale) * 0.2f;
                
                int mid = (game.min_range + game.max_range) / 2;
                int quarter = (game.min_range + mid) / 2;
                int three_quarter = (mid + game.max_range) / 2;
                
                if (ImGui::Button("Min", ImVec2(qp_w, 36 * app.dpi_scale))) { game.guess = game.min_range; game.make_guess(); }
                ImGui::SameLine(0, 8 * app.dpi_scale);
                if (ImGui::Button("25%", ImVec2(qp_w, 36 * app.dpi_scale))) { game.guess = quarter; game.make_guess(); }
                ImGui::SameLine(0, 8 * app.dpi_scale);
                if (ImGui::Button("50%", ImVec2(qp_w, 36 * app.dpi_scale))) { game.guess = mid; game.make_guess(); }
                ImGui::SameLine(0, 8 * app.dpi_scale);
                if (ImGui::Button("75%", ImVec2(qp_w, 36 * app.dpi_scale))) { game.guess = three_quarter; game.make_guess(); }
                ImGui::SameLine(0, 8 * app.dpi_scale);
                if (ImGui::Button("Max", ImVec2(qp_w, 36 * app.dpi_scale))) { game.guess = game.max_range; game.make_guess(); }
                
                ImGui::PopStyleColor(3);
                
            } else {
                // Won state
                ImGui::Spacing();
                
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.18f, 0.55f, 0.30f, 1.00f));
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.25f, 0.65f, 0.35f, 1.00f));
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.14f, 0.45f, 0.25f, 1.00f));
                if (ImGui::Button("Play Again", ImVec2(-1, 48 * app.dpi_scale))) {
                    game.reset();
                }
                ImGui::PopStyleColor(3);
            }
            
            // Guess history
            if (!game.guess_history.empty()) {
                ImGui::Spacing();
                ImGui::Separator();
                ImGui::Spacing();
                
                ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.60f, 0.65f, 0.72f, 1.00f));
                ImGui::Text("History (%zu)", game.guess_history.size());
                ImGui::PopStyleColor();
                
                ImGui::BeginChild("History", ImVec2(0, 160 * app.dpi_scale), true, 
                    ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_HorizontalScrollbar);
                
                for (int i = (int)game.guess_history.size() - 1; i >= 0; --i) {
                    int g = game.guess_history[i];
                    ImVec4 entry_color = ImVec4(0.75f, 0.78f, 0.82f, 1.00f);
                    const char* indicator = "";
                    
                    if (g < game.secret_number) {
                        entry_color = ImVec4(1.00f, 0.75f, 0.30f, 1.00f);
                        indicator = " ^";
                    } else if (g > game.secret_number) {
                        entry_color = ImVec4(1.00f, 0.45f, 0.45f, 1.00f);
                        indicator = " v";
                    } else {
                        entry_color = ImVec4(0.40f, 0.85f, 0.40f, 1.00f);
                        indicator = " *";
                    }
                    
                    ImGui::PushStyleColor(ImGuiCol_Text, entry_color);
                    ImGui::Text("#%-2zu  %d%s", game.guess_history.size() - i, g, indicator);
                    ImGui::PopStyleColor();
                }
                
                ImGui::EndChild();
            }
            
            ImGui::PopStyleVar();
        }
        
        ImGui::End();
        
        // Rendering
        ImGui::Render();
        
        // Clear with background color
        SDL_SetRenderDrawColor(app.renderer, 15, 18, 25, 255);
        SDL_RenderClear(app.renderer);
        
        // Render ImGui
        ImGui_ImplSDLRenderer2_RenderDrawData(ImGui::GetDrawData(), app.renderer);
        
        // Present
        SDL_RenderPresent(app.renderer);
    }
    
    // Cleanup
    ImGui_ImplSDLRenderer2_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
    
    SDL_DestroyRenderer(app.renderer);
    SDL_DestroyWindow(app.window);
    SDL_Quit();
    
    return 0;
}