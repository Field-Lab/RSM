#include <matrix.h>
#include <mex.h>   
#include <Random.h>

#define NDIMS_A 2
#define NDIMS_B 3

// Peter:
// This code generates an entire random matrix. It uses a random number generator to choose between 8 different colos specified in a lut. 0
// This is a specialized small lut designed for producing binary random noise matrices: lut_in_mxarray
// This is lut is constructed in Set_Lut_Placeholder 

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
    
    int w, h;
    //int width, height, r_index, g_index, b_index, lut_index;
    int width, height, mat_index, lut_index;

     //associate pointers
    state = (SInt64 *)mxGetData( prhs[0] );
    
    // Retrieve input scalar size values
    width = mxGetScalar(prhs[1]);
    height = mxGetScalar(prhs[2]);
    
    // Retrieve lut 
    lut_in_mxarray = mxDuplicateArray(prhs[3]);  
    lut = (unsigned char *)mxGetData( lut_in_mxarray );
    
    // set up variable for rng draw
    const mwSize dims_A[]={1,1};
    plhs[0] = mxCreateNumericArray(NDIMS_A,dims_A,mxINT16_CLASS,mxREAL);
    draw = (SInt16 *)mxGetData( plhs[0] );
  
    //associate outputs
    // dummy the size of the mat and try to pre-fill with dummy alpha channel values
    const mwSize dims_B[]= {4,width,height};//{4,height,width}; //{4,width,height};
    plhs[1] = mxCreateNumericArray(NDIMS_B,dims_B,mxUINT8_CLASS,mxREAL);
    
    image_mat = (unsigned char *)mxGetData( plhs[1] );

    // from random matrix fill
        for( h=0; h<height; h++) {  
        
            for( w=0; w<width; w++) {
                    
                // Draw number
                *draw = Rand3BitJavaStyle( state );                
                //mexPrintf("\n Draw: %d", *draw );
                
                //mat_index = (w * (4 * height)) + (4 * h);
                mat_index = (h * (4 * width)) + (4 * w);
                
                // lut is a single vector (r1, g1, b1, r2, g2...
                lut_index = (int)(*draw * 3);
                
                // Fill out matrix
                image_mat[ mat_index ] = lut[ lut_index ];  //  R
                
                image_mat[ mat_index+1 ] = lut[ lut_index+1 ];  // G
                 
                image_mat[ mat_index+2 ] = lut[ lut_index + 2];  // B
                 
                image_mat[ mat_index+3 ] = (unsigned char)0xff;     // Fill the 4th color (alpha) channel with 255 as a filler
                
                
            }       // height
        }           // width
    

    return;
}