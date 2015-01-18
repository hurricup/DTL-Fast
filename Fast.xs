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
    
    void*           dst_buffer = malloc(buffer_length);
    unsigned int    dst_offset = 0;
    
    bool             remove = true;
    unsigned int     remove_src_offset = 0;
    
    for( src_offset = 0; src_offset < buffer_length; src_offset++ )
    {
        unsigned char symbol = *(unsigned char*)(src_buffer + src_offset);
        if( symbol == '>' )
        {
            remove = true;
            remove_src_offset = src_offset + 1;
        }
        else if( symbol == '<' )
        {
            if( remove )
            {
                int remove_bytes = src_offset - remove_src_offset;
                if( remove_bytes > 0 )
                {
                    memcpy( src_buffer + remove_src_offset, src_buffer + src_offset, buffer_length - src_offset );
                    buffer_length -= remove_bytes;
                    src_offset = remove_src_offset;
                    remove = false;
                }
            }
        }
        else if( whitespace[symbol] != 1 ) // non white-space symbol
        {
            remove = false;
        }
    }
    
    if( remove )
    {
        buffer_length = remove_src_offset;
    }
    
    SvCUR_set(sv_string_ptr, buffer_length);
}

MODULE = DTL::Fast  PACKAGE = DTL::Fast

SV*
spaceless( SV* sv_string_ptr )
    CODE:
        RETVAL = _spaceless( aTHX_ sv_string_ptr );
    OUTPUT:
        RETVAL