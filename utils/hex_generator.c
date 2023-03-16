#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void hex_generator (char *filename, int depth_p, int width_p, int fresh) {
    FILE *fp;
    width_p = width_p / 8;
    fp = fopen(filename, "w");
    if (fp == NULL) {
        printf("Could not open file %s\n", filename);
        return;
    }
    srand(time(NULL));
    for (int i = 0; i < depth_p; i++) {
        for (int j = 0; j < width_p; j++) {
            int num;
            if (fresh) {
                num = 0;
            } else {
                num = rand() % 256;
            }
            if (j == width_p-1) {
                fprintf(fp, "%02X", num);
            } else {
                fprintf(fp, "%02X ", num);
            }
        }
        if (i != depth_p-1) {
            fprintf(fp, "\n");
        }
    }
    fclose(fp);
    return;
}

int main() {
    hex_generator("memory_enemy.hex", 64, 21, 1);
    hex_generator("memory_bullets.hex", 2, 20, 1);
    return 0;
}
