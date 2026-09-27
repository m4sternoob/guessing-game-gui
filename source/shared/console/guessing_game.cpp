// Guessing Game - Original Console Version (Day 1 C++)
// This is the foundational console game that the GUI version was built upon.
// Original logic: random number generation, range input, guess loop with hints.

#include <iostream>
#include <random>
#include <string>
#include <limits>

int main() {
    std::random_device rd;
    std::mt19937 gen(rd());
    
    int min_range = 1;
    int max_range = 100;
    int guess = 0;
    int attempts = 0;
    
    std::cout << "========================================\n";
    std::cout << "   Welcome to the GUESSING GAME!        \n";
    std::cout << "========================================\n\n";
    
    // Get range from user
    std::cout << "Enter minimum number: ";
    while (!(std::cin >> min_range) || min_range < 1) {
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        std::cout << "Invalid input. Enter a positive integer: ";
    }
    
    std::cout << "Enter maximum number: ";
    while (!(std::cin >> max_range) || max_range <= min_range) {
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        std::cout << "Invalid input. Enter a number greater than " << min_range << ": ";
    }
    
    // Generate secret number
    std::uniform_int_distribution<int> dist(min_range, max_range);
    int secret_number = dist(gen);
    
    std::cout << "\nI've generated a number between " << min_range 
              << " and " << max_range << ". Try to guess it!\n\n";
    
    // Guessing loop
    while (true) {
        std::cout << "Enter your guess: ";
        if (!(std::cin >> guess)) {
            std::cin.clear();
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            std::cout << "Please enter a valid number.\n";
            continue;
        }
        
        if (guess < min_range || guess > max_range) {
            std::cout << "Guess must be between " << min_range << " and " << max_range << "!\n";
            continue;
        }
        
        attempts++;
        
        if (guess == secret_number) {
            std::cout << "\n========================================\n";
            std::cout << "  🎉 YOU WON!                            \n";
            std::cout << "  The number was " << secret_number << "\n";
            std::cout << "  Guessed in " << attempts << " attempt(s)!\n";
            std::cout << "========================================\n";
            break;
        } else if (guess < secret_number) {
            std::cout << "📈 Too low! Try higher.\n";
        } else {
            std::cout << "📉 Too high! Try lower.\n";
        }
    }
    
    return 0;
}