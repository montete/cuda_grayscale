#include "io.h"

#include <stdio.h>
#include <stdlib.h>
#include "lodepng.h"


void processImage(const char *filename, rgb_image *img)
{
    decodeTwoSteps(filename, img);
    transformToGray(img);
    encodeOneStep("wynik.png", img);
}

void encodeOneStep(const char* filename, rgb_image *img)
{
  /*Encode the image*/
  unsigned error = lodepng_encode32_file(filename, img->image, img->width, img->height);

  /*if there's an error, display it*/
  if(error) printf("error %u: %s\n", error, lodepng_error_text(error));
}

void decodeTwoSteps(const char* filename, rgb_image *img)
{
  unsigned error;
  unsigned char* png;
  size_t pngsize;;
  unsigned x, y;
  float gray;

  lodepng_load_file(&png, &pngsize, filename);
  error = lodepng_decode32(&img->image, &img->width, &img->height, png, pngsize);
  if(error) printf("error %u: %s\n", error, lodepng_error_text(error));

  free(png);
}


void transformToGray(rgb_image *img)
{
    unsigned char* image = img->image;
    unsigned width = img->width;
    unsigned height = img->height;
    unsigned x, y;
    float gray;
    float r, g, b, a;
    a = 255;

    for(y = 0; y < height; y++)
        for(x=0; x< width; x++)
        {
            r = image[4 * width * y + 4 * x + 0];
            g = image[4 * width * y + 4 * x + 1];
            b = image[4 * width * y + 4 * x + 2];
            gray = .299f*r + .587f*g + .114f*b;
            image[4 * width * y + 4 * x + 0] = gray;
            image[4 * width * y + 4 * x + 1] = gray;
            image[4 * width * y + 4 * x + 2] = gray;
            image[4 * width * y + 4 * x + 3] = a;
        }

}
