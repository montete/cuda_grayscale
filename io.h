#ifndef IO_H
#define IO_H
typedef struct{
    unsigned width;
    unsigned height;
    unsigned char *image; //RGBA
}rgb_image;


/*void transformToGray(rgb_image *img);
void transformToGrayCuda(rgb_image *img);
void decodeTwoSteps(const char* filename, rgb_image *img);
void encodeOneStep(const char* filename, rgb_image *img);
void processImage(const char *filename, rgb_image *img); */


#endif // IO_H
