#include "math.h"
#include <matrix.h>
#include <mex.h>   
#include <Random.h>
#include <stdio.h>
#include <stdlib.h>

#define NDIMS_A 2
#define NDIMS_B 3


/*
SInt16 Rand3BitJavaStyle(RandJavaState state) {
  *state = (*state * 0x5DEECE66DLL + 0xBLL) & 0xFFFFFFFFFFFFLL;
  return (SInt16) (*state >> 45LL); // 32 shifts you enough to get to SInt16, 45 seems to shift you till you have only 3 valid bits left!
}
*/

SInt32 RandJavaLong(RandJavaState state) {
  *state = (*state * 0x5DEECE66DLL + 0xBLL) & 0xFFFFFFFFFFFFLL;
  return (SInt32) (*state >> 16LL);
}


float RandJavaFloat(RandJavaState state)
{
    return(RandJavaLong(state)/RANDJAVA_SCALE + 0.5); 
}





int Binary_Search_4_Mark(float cdf_vect[], float y_mark, int start_ind, int stop_ind )
{
    int mid_ind;
    
    mid_ind = (int)floor( ((stop_ind - start_ind)/2) ) + start_ind;
     
    // Testing for completion / recursion branch
    if (mid_ind == start_ind)  // then we are done
    {    
        
       return (int)stop_ind;  // return the index for the entry just higher than the mark
    }     
    else 
    {    
           if ( cdf_vect[mid_ind] > y_mark )  // then the mid-point y value is higher than the mark, look lower down
           {
               return Binary_Search_4_Mark(cdf_vect, y_mark, start_ind, mid_ind);
               
           }
           else
           {
               return Binary_Search_4_Mark(cdf_vect, y_mark, mid_ind, stop_ind);
               
           }     // close of greater-less-than
           
    } // close of test for finish

}





// No checking... should there be safety checking? like for lut_index beyo1nd bound?what about proper num inputs?

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])    
{
    
    float *draw, *cdf;  
    SInt64 *state;
    mxArray *lut_in_mxarray, *cdf_in_mxarray;
    //unsigned char *lut, *image_mat; // unsigned char is uint8;
    unsigned char *lut, *image_mat;
    int w, h, width, height, mat_index, lut_index, cdf_index, stop_ind;
    //double draw_dbl;
    

    //associate pointers
    state = (SInt64 *)mxGetData( prhs[0] );
    
    // Retrieve input scalar size values
    width = mxGetScalar(prhs[1]);
    height = mxGetScalar(prhs[2]);
    
    // Retrieve lut 
    lut_in_mxarray = mxDuplicateArray(prhs[3]);  
    lut = (unsigned char *)mxGetData( lut_in_mxarray );//(unsigned char *)mxGetData( lut_in_mxarray );
    
    // Retrieve cdf array 
    cdf_in_mxarray = mxDuplicateArray(prhs[4]);  
    cdf = (float *)mxGetData( cdf_in_mxarray );
   
    stop_ind = mxGetScalar(prhs[5]); // This is the lendth of the cdf lut. It is intended to be passed from matlab.
                                    
    stop_ind = stop_ind - 1;    // For proper index function I subtract 1 to account for C's 0 to n-1 addressing.
    
     
    // set up variable for rng draw
    const mwSize dims_A[]={1,1};
    plhs[0] = mxCreateNumericArray(NDIMS_A,dims_A,mxSINGLE_CLASS,mxREAL);
    draw = (float *)mxGetData( plhs[0] );
  
    //associate outputs
    // dummy the size of the mat and try to pre-fill with dummy alpha channel values
    const mwSize dims_B[]= {4,width,height};//{4,height,width}; //{4,width,height};
    plhs[1] = mxCreateNumericArray(NDIMS_B,dims_B,mxUINT8_CLASS,mxREAL);
    
    image_mat = (unsigned char *)mxGetData( plhs[1] );//(unsigned char *)mxGetData( plhs[1] );

    
        for( h=0; h<height; h++) {  
        
            for( w=0; w<width; w++) {
                    
                // Draw number
                *draw = RandJavaFloat( state );  
                //draw_dbl = ( (((double)*draw)+1) / 8); 
                //mexPrintf("\n Draw: %3.3f", *draw );
                
                //mat_index = (w * (4 * height)) + (4 * h);
                mat_index = (h * (4 * width)) + (4 * w);
                 
                 
                cdf_index = Binary_Search_4_Mark(cdf, *draw, 0, stop_ind);
                
                                // lut is a single vector (r1, g1, b1, r2, g2...
                lut_index = (int)(cdf_index * 3);

                
                // Fill out matrix
                image_mat[ mat_index ] = lut[ lut_index ];  //  R
                
                image_mat[ mat_index+1 ] = lut[ lut_index+1 ];  // G
                 
                image_mat[ mat_index+2 ] = lut[ lut_index + 2];  // B
                 
                image_mat[ mat_index+3 ] = (unsigned char)0xff;     // Fill the 4th color (alpha) channel with 255 as a filler
                
                
            }       // height
        }           // width
    

    return;
}  // mex file