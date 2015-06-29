#ifndef KUDA_H
#define KUDA_H

void decodeTwoSteps(const char* filename, rgb_image *img);
void encodeOneStep(const char* filename, rgb_image *img);
void transformToGrayCuda(rgb_image *img);
__global__ void setPixelToGrayscale(unsigned char *image, unsigned width, unsigned height);

#endif ;