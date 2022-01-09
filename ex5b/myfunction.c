#include <stdbool.h> 

typedef struct {
   unsigned char red;
   unsigned char green;
   unsigned char blue;
} pixel;

typedef struct {
    int red;
    int green;
    int blue;
    // int num;
} pixel_sum;

/*
 *  Applies kernel for pixel at (i,j)
 */
static void applyKernel(int dim, int i, int j, unsigned char *src, int kernelType, int kernelScale, bool filter, char* dst) {

	int ii, jj;
	int currRow, currCol;
	pixel_sum sum = {0,0,0};
	int min_intensity = 766; // arbitrary value that is higher than maximum possible intensity, which is 255*3=765
	int max_intensity = -1; // arbitrary value that is lower than minimum possible intensity, which is 0
	int min_row, min_col, max_row, max_col;
	pixel loop_pixel;
	int n3 = dim*3;
	int ni = n3*i - n3;
	int j3 = 3*j - 3;

	for(ii = i-1; ii <= i+1; ++ii) {
		for(jj = j-1; jj <= j+1; ++jj) {
			// apply kernel on pixel at [ii,jj]
			sum.red += (int) src[ni + j3];
			sum.green += (int) src[ni + j3 + 1];
			sum.blue += (int) src[ni + j3 + 2];

			if (filter) {
				loop_pixel.red = src[ni + j3];
				loop_pixel.green = src[ni + j3 + 1];
				loop_pixel.blue = src[ni + j3 + 2];
				int pixel_intensity = (((int) loop_pixel.red) + ((int) loop_pixel.green) + ((int) loop_pixel.blue));
				if (pixel_intensity <= min_intensity) {
					min_intensity = pixel_intensity;
					min_row = ni;
					min_col = j3;
				}
				if (pixel_intensity > max_intensity) {
					max_intensity = pixel_intensity;
					max_row = ni;
					max_col = j3;
				}
			}
			j3 += 3;
		}
		j3 -= 9;
		ni += n3;
	}

	if (kernelType == 9) {
		sum.red = -1 * sum.red;
		sum.green = -1 * sum.green;
		sum.blue = -1 * sum.blue;
		int baseIndex = ni - n3 - n3 + j3 + 3;
		sum.red += 10 * (int) src[baseIndex];
		sum.green += 10 * (int) src[baseIndex + 1];
		sum.blue += 10 * (int) src[baseIndex + 2];
	}

	if (filter) {
		// filter out min and max
		int minIdx = (min_row + min_col);
		int maxIdx = (max_row + max_col);
		sum.red -= ((int) src[minIdx] + (int) src[maxIdx]);
		sum.green -= ((int) src[minIdx + 1] + (int) src[maxIdx + 1]);
		sum.blue -= ((int) src[minIdx + 2] + (int) src[maxIdx + 2]);
	}

	// assign kernel's result to pixel at [i,j]
	// divide by kernel's weight
	if (kernelScale != 1) {
		if (kernelScale == 9) {
			sum.red = sum.red / 9;
			sum.green = sum.green / 9;
			sum.blue = sum.blue / 9;
		} else if (kernelScale == 7) {
			sum.red = sum.red / 7;
			sum.green = sum.green / 7;
			sum.blue = sum.blue / 7;
		}
	}
	// truncate each pixel's color values to match the range [0,255]
	if (kernelType == 9) {
		int a1 = (sum.red > 0 ? sum.red : 0);
		dst[0] = (unsigned char) (a1 < 255 ? a1 : 255);
		a1 = (sum.green > 0 ? sum.green : 0);
		dst[1] = (unsigned char) (a1 < 255 ? a1 : 255);
		a1 = (sum.blue > 0 ? sum.blue : 0);
		dst[2] = (unsigned char) (a1 < 255 ? a1 : 255);
	} else {
		dst[0] = (unsigned char) sum.red;
		dst[1] = (unsigned char) sum.green;
		dst[2] = (unsigned char) sum.blue;
	}
}

/*
* Apply the kernel over each pixel.
* Ignore pixels where the kernel exceeds bounds. These are pixels with row index smaller than kernelSize/2 and/or
* column index smaller than kernelSize/2
*/
void smooth(int dim, char *src, char *dst, int kernelType, int kernelScale, bool filter) {

	int i, j;
	int jMax = dim-1;
	int iMax = m-1;
	int n3 = 3*dim;
	int j3 = 0;
	int in = 0;
	int idx;
	// first line - same as image
	for (j = 0; j < dim; ++j) {
		dst[j3] = src[j3]; dst[j3+1] = src[j3+1]; dst[j3+2] = src[j3+2];
		j3 += 3; 
	}
	// the other rows
	for (i = 1 ; i < iMax; ++i) {
		in += n3;
		j3 = 0;
		// first column - same as image
		dst[in] = src[in]; dst[in+1] = src[in+1]; dst[in+2] = src[in+2]; 
		// the other columns
		for (j =  1 ; j < jMax ; ++j) {
			j3 += 3;
			applyKernel(dim, i, j, src, kernelType, kernelScale, filter, &dst[in + j3]);
		}
		// last column - same as image
		idx = in + j3 + 3; 
		dst[idx] = src[idx]; dst[idx+1] = src[idx+1]; dst[idx+2] = src[idx+2]; 
	}
	// last row - same as image
	in += n3;
	j3 = 0;
	for (j = 0; j < m; ++j) {
		idx = in + j3;
		dst[idx] = src[idx]; dst[idx+1] = src[idx+1]; dst[idx+2] = src[idx+2]; 
		j3 += 3;
	}
}

void doConvolution(Image *image, int kernelType, int kernelScale, bool filter) {

	char* imageData = image->data;
	char* cpyData = (char*) malloc(3*m*m);
	
	smooth(m, imageData, cpyData, kernelType, kernelScale, filter);

	free(imageData);
	image->data = cpyData;

}

void myfunction(Image *image, char* srcImgpName, char* blurRsltImgName, char* sharpRsltImgName, char* filteredBlurRsltImgName, char* filteredSharpRsltImgName, char flag) {

	/*
	* [1, 1, 1]
	* [1, 1, 1]
	* [1, 1, 1]
	*/
	int blurKernel[3][3] = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}};

	/*
	* [-1, -1, -1]
	* [-1, 9, -1]
	* [-1, -1, -1]
	*/
	int sharpKernel[3][3] = {{-1,-1,-1},{-1,9,-1},{-1,-1,-1}};

	if (flag == '1') {	
		// blur image
		doConvolution(image, 1, 9, false);

		// write result image to file
		writeBMP(image, srcImgpName, blurRsltImgName);	

		// sharpen the resulting image
		doConvolution(image, 9, 1, false);
		
		// write result image to file
		writeBMP(image, srcImgpName, sharpRsltImgName);	
	} else {
		// apply extermum filtered kernel to blur image
		doConvolution(image, 1, 7, true);

		// write result image to file
		writeBMP(image, srcImgpName, filteredBlurRsltImgName);

		// sharpen the resulting image
		doConvolution(image, 9, 1, false);

		// write result image to file
		writeBMP(image, srcImgpName, filteredSharpRsltImgName);	
	}
}

