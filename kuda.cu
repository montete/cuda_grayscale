#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "io.h"
#include "kuda.h"
#include "lodepng.h"

void decodeTwoSteps(const char* filename, rgb_image *img)
{
  unsigned error;
  unsigned char* png;
  size_t pngsize;;
  
  lodepng_load_file(&png, &pngsize, filename);
  error = lodepng_decode32(&img->image, &img->width, &img->height, png, pngsize);
  if(error) printf("error %u: %s\n", error, lodepng_error_text(error));

  
}

void encodeOneStep(const char* filename, rgb_image *img)
{
  /*Encode the image*/
  unsigned error = lodepng_encode32_file(filename, img->image, img->width, img->height);

  /*if there's an error, display it*/
  if(error) printf("error %u: %s\n", error, lodepng_error_text(error));
}
void transformToGrayCuda(rgb_image *img){
	
	
	
	unsigned char* image = img->image;
    unsigned char* image_d;
    unsigned width = img->width;
    unsigned height = img->height;
    int N = (int)width * (int)height; 
    size_t size = N * 4 * sizeof(unsigned char);
	
    
	int device_count = 0;
	cudaError_t status = cudaGetDeviceCount(&device_count);
	
	status = cudaMalloc((void **) &image_d, size);
	
	
	clock_t timer_start = clock();
	
	cudaMemcpy(image_d, image,  size, cudaMemcpyHostToDevice);
	
	clock_t timer_diff = clock() - timer_start;
	printf("CZas kopiowania RAM-CUDA: %gs\n", (timer_diff / (double)CLOCKS_PER_SEC));
	
	dim3 block_size(16, 16);
	dim3 num_blocks(img->width / block_size.x, img->height / block_size.y);
    setPixelToGrayscale<<<num_blocks, block_size>>>(image_d, img->width, img->height);
    
	timer_start = clock();
	
	cudaMemcpy(image, image_d, size, cudaMemcpyDeviceToHost);
	
	clock_t timer_diff2 = clock() - timer_start;
	
	printf("CZas kopiowania CUDA-RAM: %gs\n", (timer_diff2 / (double)CLOCKS_PER_SEC));
	cudaFree(image_d);
	
	
}

__global__
void setPixelToGrayscale(unsigned char *image, unsigned width, unsigned height)
{
    float gray;
    float r, g, b;
	
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < width && y < height) {
		r = image[4 * width * y + 4 * x + 0];
		g = image[4 * width * y + 4 * x + 1];
		b = image[4 * width * y + 4 * x + 2];
		gray = .299f*r + .587f*g + .114f*b;
		image[4 * width * y + 4 * x + 0] = gray;
		image[4 * width * y + 4 * x + 1] = gray;
		image[4 * width * y + 4 * x + 2] = gray;
		image[4 * width * y + 4 * x + 3] = 255;
	}
	
}


int main(int argc, char *argv[])
{
	const char* filename = argc > 1 ? argv[1] : "test.png";
	rgb_image img;
	
	decodeTwoSteps(filename, &img);
	transformToGrayCuda(&img);
	encodeOneStep("wynik3.png", &img);
	
	return 0;
}

