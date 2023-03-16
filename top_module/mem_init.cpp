#include <fstream>
#include <iostream>

int main(){
    std::ofstream emeny_file("memory_enemy.hex");
    std::ofstream bullet_file("memory_bullets.hex");
    uint32_t y_position_enemy = 0xa;
    uint32_t x_position_enemy = 0xa;
    uint32_t y_position_bullet = 0xaa;
    uint32_t x_position_bullet = 0xa;
    uint32_t enemy_info = (y_position_enemy << 16) | x_position_enemy;
    uint32_t bullet_info = (y_position_bullet << 16) | x_position_bullet;
    for(int i = 0; i < 5; i++){
        for (int j = 0; j < 11; j++){
            emeny_file << std::hex << enemy_info << "\n";
            x_position_enemy = x_position_enemy + 40;
            enemy_info = (y_position_enemy << 16) | x_position_enemy;
            
        }
        x_position_enemy = 0xa;
        y_position_enemy = y_position_enemy + 40;
        enemy_info = (y_position_enemy << 16) | x_position_enemy;
    }
    for(int k = 0; k < 4; k++){
            bullet_file << std::hex << bullet_info << "\n";
            x_position_bullet = x_position_bullet + 40;
            bullet_info = (y_position_bullet << 16) | x_position_bullet;
        
    }
    return 0;
}