#include <matrix.h>
#include <mex.h>  
#include "Random.h"
#include "stdio.h"

#define NDIMS_A 2
#define NDIMS_B 3

// inputs
// width, height, lut in mxarray, map_in_mxarray, backrgb vect (3 element) 

// Peter:
// This code generates an entire random matrix. It uses a random number generator to choose between 8 different colos specified in a lut. 0
// This is a specialized small lut designed for producing binary random noise matrices: lut_in_mxarray
// This is lut is constructed in Set_Lut_Placeholder 

// Alex:
// call with seed first, so arguments shifted left by 1 from Make_Map

// Returns 0 to 7 Yay!!

SInt16 Rand3BitJavaStyle(RandJavaState state) {
  *state = (*state * 0x5DEECE66DLL + 0xBLL) & 0xFFFFFFFFFFFFLL;
  return (SInt16) (*state >> 45LL); // 32 shifts you enough to get to SInt16, 45 seems to shift you till you have only 3 valid bits left!
}

// No checking... should there be safety checking? like for lut_index beyo1nd bound?what about proper num inputs?

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])    
{
    
    SInt16 *draw;
    SInt64 *state;
    unsigned char *image_mat; // unsigned char is uint8
    
    mxArray *lut_in_mxarray;
    unsigned char *lut;
    
    mxArray *map_in_mxarray;
    unsigned short *map;
    
    mxArray *backrgb_in_mxarray;
    unsigned char *backrgb;

    
    int w, h;
    //int width, height, r_index, g_index, b_index, lut_index;
    int width, height, map_index, image_index, lut_index, map_value, max_map;
    
    //associate pointers
    state = (SInt64 *)mxGetData( prhs[0] );
    
    // Retrieve input scalar size values
    width = mxGetScalar(prhs[1]);
    height = mxGetScalar(prhs[2]);
    
    // Retrieve lut 
    lut_in_mxarray = mxDuplicateArray(prhs[3]);  
    lut = (unsigned char *)mxGetData( lut_in_mxarray );
    
    // Retrieve map
    map_in_mxarray = mxDuplicateArray(prhs[4]);  
    map = (unsigned char *)mxGetData( map_in_mxarray );

    // Retrieve back rgb vect
    backrgb_in_mxarray = mxDuplicateArray(prhs[5]);  
    backrgb = (unsigned char *)mxGetData( backrgb_in_mxarray );
    
    // max map value
    max_map = mxGetScalar(prhs[6]);
    

    // set up variable for rng draw
    const mwSize dims_A[]={1,1};
    plhs[0] = mxCreateNumericArray(NDIMS_A,dims_A,mxINT16_CLASS,mxREAL);
    draw = (SInt16 *)mxGetData( plhs[0] );
   
    //associate outputs
    // dummy the size of the mat and try to pre-fill with dummy alpha channel values
    const mwSize dims_B[]= {4,width,height};//{4,height,width}; //{4,width,height};
    plhs[1] = mxCreateNumericArray(NDIMS_B,dims_B,mxUINT8_CLASS,mxREAL);
    
    image_mat = (unsigned char *)mxGetData( plhs[1] );

    int all_random_numbers[max_map];
    
    for( h=0; h<max_map; h++) {
        *draw = Rand3BitJavaStyle( state );
        all_random_numbers[h] = *draw;
    }
    // from random matrix fill
        for( h=0; h<height; h++) {  
        
            for( w=0; w<width; w++) {
                
                // Draw number
                
       
                image_index = (h * (4 * width)) + (4 * w);
                map_index = (h * width) + w;
                map_value = (int)map[ map_index ];

   
                // Fill out first three color entries in relevant matrix index 
                if ( map_value < 1 ) {
     
                    image_mat[ image_index ] = backrgb[0];  //  R
                
                    image_mat[ image_index + 1 ] = backrgb[1];  // G
                 
                    image_mat[ image_index + 2 ] = backrgb[2];  // B
                }
                else {                    
 
                    //lut_index = (int)(3 * (map_value - 1)); // from Make_Map.c
                    lut_index = (int)(all_random_numbers[map_value-1] * 3); // from Random_Texture_Binary_LUT.c

                    image_mat[ image_index ] = lut[ lut_index ];  //  R
                    
                    image_mat[ image_index + 1 ] = lut[ lut_index + 1 ];  // G
                 
                    image_mat[ image_index + 2 ] = lut[ lut_index + 2];  // B
                }
                 
                image_mat[ image_index + 3 ] = (unsigned char)0xff;     // Fill the 4th color (alpha) channel with 255 as a filler
                
            }       // height
        }           // width
    

    return;
}