#define PERL_NO_GET_CONTEXT 

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define true 1
#define false 0

unsigned char whitespace[256] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, // 00-15
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 16-31
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 32-47  "'" 39, "(" 40, ")" 41, "-" 45, "." 46,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 48-63 DIGIT 48-57
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 64-79 ALPHA 65-90
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 80-95 "_" 95,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 96-111 alpha 97-122
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 112-127 "~" 126,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 128-143
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 144-159
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 160-175
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 176-191
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 192-207
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 208-223
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 224-239
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  // 240-255
};

// not utf safe i belive
SV* _spaceless(pTHX_ SV* sv_string_ptr)
{
    void*           src_buffer = (void*)SvPV_nolen(sv_string_ptr);
    unsigned int    src_buffer_length = SvCUR(sv_string_ptr);
    unsigned int    src_offset = 0;
    
//    void*           dst_buffer = malloc(src_buffer_length);
    void*           dst_buffer = src_buffer;
    unsigned int    dst_offset = 0;
    
    bool            space = true;
    unsigned int    copy_offset = 0;
    
    for( src_offset = 0; src_offset < src_buffer_length; src_offset++ )
    {
        unsigned char symbol = *(unsigned char*)(src_buffer + src_offset);
        
        if( symbol == '<' )
        {
            if( space )
            {
                copy_offset = src_offset;
            }
            space = false;
        }
        else if( symbol == '>' )
        {
            unsigned int copy_bytes = src_offset  + 1 - copy_offset;

            if( dst_offset != copy_offset )
            {
                memcpy( dst_buffer + dst_offset, src_buffer + copy_offset, copy_bytes );
            }
            
            dst_offset += copy_bytes;

            copy_offset = src_offset + 1;
            space = true;
        }
        else if( whitespace[symbol] != 1 ) // non white-space symbol
        {
            space = false;
        }
    }
    
    if( !space )
    {
        unsigned int copy_bytes = src_buffer_length - copy_offset;
    
        if( copy_bytes > 0 )
        {
            if( dst_offset != copy_offset )
            {
                memcpy( dst_buffer + dst_offset, src_buffer + copy_offset, copy_bytes );
            }
            dst_offset += copy_bytes;
        }
    }

    SvCUR_set(sv_string_ptr, dst_offset);
    // freing buffer
    /*
    SV* sv_result = newSVpvn(dst_buffer, dst_offset);

    free(dst_buffer);
    return(sv_result);
    */
}

MODULE = DTL::Fast  PACKAGE = DTL::Fast

SV*
spaceless( SV* sv_string_ptr )
    CODE:
        _spaceless( aTHX_ sv_string_ptr );
