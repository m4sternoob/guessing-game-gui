// Animation System - Flip cards, easing, particles

#pragma once

#include <vector>
#include <cmath>
#include <imgui.h>

#ifndef IM_PI
#define IM_PI 3.14159265359f
#endif

struct Particle {
    ImVec2 pos;
    ImVec2 vel;
    ImVec4 color;
    float life;
    float max_life;
    float size;
    bool active = true;
    
    Particle(ImVec2 p, ImVec2 v, ImVec4 c, float l, float s)
        : pos(p), vel(v), color(c), life(l), max_life(l), size(s) {}
    
    void update(float dt) {
        pos.x += vel.x * dt;
        pos.y += vel.y * dt;
        vel.y += 200.0f * dt; // gravity
        life -= dt;
        if (life <= 0) active = false;
    }
};

class ParticleSystem {
public:
    std::vector<Particle> particles;
    
    void emit_burst(ImVec2 center, int count, ImVec4 color, float speed_range = 300.0f) {
        for (int i = 0; i < count; ++i) {
            float angle = (float)i / (float)count * 2.0f * IM_PI;
            float speed = speed_range * (0.5f + 0.5f * ((float)rand() / (float)RAND_MAX));
            ImVec2 vel = ImVec2(cosf(angle) * speed, sinf(angle) * speed - 100.0f);
            float life = 0.8f + 0.4f * ((float)rand() / (float)RAND_MAX);
            float size = 4.0f + 4.0f * ((float)rand() / (float)RAND_MAX);
            particles.emplace_back(center, vel, color, life, size);
        }
    }
    
    void emit_confetti(ImVec2 center, int count) {
        ImVec4 colors[] = {
            ImVec4(1.0f, 0.3f, 0.3f, 1.0f),
            ImVec4(0.3f, 1.0f, 0.3f, 1.0f),
            ImVec4(0.3f, 0.5f, 1.0f, 1.0f),
            ImVec4(1.0f, 0.8f, 0.2f, 1.0f),
            ImVec4(1.0f, 0.4f, 1.0f, 1.0f),
            ImVec4(0.2f, 1.0f, 1.0f, 1.0f),
        };
        for (int i = 0; i < count; ++i) {
            float angle = (float)rand() / (float)RAND_MAX * 2.0f * IM_PI;
            float speed = 200.0f + 300.0f * ((float)rand() / (float)RAND_MAX);
            ImVec2 vel = ImVec2(cosf(angle) * speed, sinf(angle) * speed - 200.0f);
            ImVec4 color = colors[rand() % 6];
            float life = 1.0f + 0.5f * ((float)rand() / (float)RAND_MAX);
            float size = 6.0f + 4.0f * ((float)rand() / (float)RAND_MAX);
            particles.emplace_back(center, vel, color, life, size);
        }
    }
    
    void update(float dt) {
        for (auto& p : particles) {
            if (p.active) p.update(dt);
        }
        // Remove dead particles
        particles.erase(
            std::remove_if(particles.begin(), particles.end(),
                [](const Particle& p) { return !p.active; }),
            particles.end()
        );
    }
    
    void render(ImDrawList* draw_list) {
        for (const auto& p : particles) {
            if (!p.active) continue;
            float alpha = p.life / p.max_life;
            ImVec4 c = p.color;
            c.w *= alpha;
            ImU32 col = ImGui::ColorConvertFloat4ToU32(c);
            draw_list->AddRectFilled(
                ImVec2(p.pos.x - p.size * 0.5f, p.pos.y - p.size * 0.5f),
                ImVec2(p.pos.x + p.size * 0.5f, p.pos.y + p.size * 0.5f),
                col
            );
        }
    }
    
    void clear() { particles.clear(); }
};

enum class FlipState {
    IDLE_FRONT,
    FLIPPING_TO_BACK,
    IDLE_BACK,
    FLIPPING_TO_FRONT
};

class FlipAnimation {
public:
    FlipState state = FlipState::IDLE_FRONT;
    float progress = 0.0f;  // 0.0 to 1.0
    float duration = 0.6f;  // seconds
    bool flip_requested = false;
    bool flip_to_back = true;
    
    void request_flip(bool to_back) {
        if (state == FlipState::IDLE_FRONT && to_back) {
            state = FlipState::FLIPPING_TO_BACK;
            progress = 0.0f;
            flip_to_back = true;
            flip_requested = true;
        } else if (state == FlipState::IDLE_BACK && !to_back) {
            state = FlipState::FLIPPING_TO_FRONT;
            progress = 0.0f;
            flip_to_back = false;
            flip_requested = true;
        }
    }
    
    void update(float dt) {
        if (state == FlipState::FLIPPING_TO_BACK || state == FlipState::FLIPPING_TO_FRONT) {
            progress += dt / duration;
            if (progress >= 1.0f) {
                progress = 1.0f;
                state = flip_to_back ? FlipState::IDLE_BACK : FlipState::IDLE_FRONT;
                flip_requested = false;
            }
        }
    }
    
    // Returns rotation angle in degrees (-90 to 90)
    float get_rotation() const {
        if (state == FlipState::FLIPPING_TO_BACK) {
            return -90.0f * ease_out_cubic(progress);
        } else if (state == FlipState::FLIPPING_TO_FRONT) {
            return 90.0f * (1.0f - ease_out_cubic(progress));
        } else if (state == FlipState::IDLE_BACK) {
            return -90.0f;
        }
        return 0.0f;
    }
    
    // Returns true if front side should be visible
    bool is_front_visible() const {
        if (state == FlipState::FLIPPING_TO_BACK) return progress < 0.5f;
        if (state == FlipState::FLIPPING_TO_FRONT) return progress > 0.5f;
        return state == FlipState::IDLE_FRONT;
    }
    
    // Returns true if back side should be visible
    bool is_back_visible() const {
        if (state == FlipState::FLIPPING_TO_BACK) return progress > 0.5f;
        if (state == FlipState::FLIPPING_TO_FRONT) return progress < 0.5f;
        return state == FlipState::IDLE_BACK;
    }
    
    float get_scale() const {
        // Slight scale down during flip for 3D effect
        if (state == FlipState::FLIPPING_TO_BACK || state == FlipState::FLIPPING_TO_FRONT) {
            float p = (state == FlipState::FLIPPING_TO_BACK) ? progress : (1.0f - progress);
            return 1.0f - 0.05f * sinf(p * IM_PI);
        }
        return 1.0f;
    }
    
private:
    static float ease_out_cubic(float t) {
        return 1.0f - powf(1.0f - t, 3.0f);
    }
};

// Easing functions
namespace Easing {
    inline float ease_out_cubic(float t) { return 1.0f - powf(1.0f - t, 3.0f); }
    inline float ease_out_quart(float t) { return 1.0f - powf(1.0f - t, 4.0f); }
    inline float ease_out_quint(float t) { return 1.0f - powf(1.0f - t, 5.0f); }
    inline float ease_out_expo(float t) { return t == 1.0f ? 1.0f : 1.0f - powf(2.0f, -10.0f * t); }
    inline float ease_out_circ(float t) { return sqrtf(1.0f - powf(t - 1.0f, 2.0f)); }
    inline float ease_out_back(float t) {
        const float c1 = 1.70158f;
        const float c3 = c1 + 1.0f;
        return 1.0f + c3 * powf(t - 1.0f, 3.0f) + c1 * powf(t - 1.0f, 2.0f);
    }
    inline float ease_out_elastic(float t) {
        const float c4 = (2.0f * IM_PI) / 3.0f;
        return t == 0.0f ? 0.0f : t == 1.0f ? 1.0f : powf(2.0f, -10.0f * t) * sinf((t * 10.0f - 0.75f) * c4) + 1.0f;
    }
    inline float ease_out_bounce(float t) {
        const float n1 = 7.5625f;
        const float d1 = 2.75f;
        if (t < 1.0f / d1) return n1 * t * t;
        else if (t < 2.0f / d1) {
            float t2 = t - 1.5f / d1;
            return n1 * t2 * t2 + 0.75f;
        }
        else if (t < 2.5f / d1) {
            float t2 = t - 2.25f / d1;
            return n1 * t2 * t2 + 0.9375f;
        }
        else {
            float t2 = t - 2.625f / d1;
            return n1 * t2 * t2 + 0.984375f;
        }
    }
}