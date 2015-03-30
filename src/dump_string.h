/* would be better to copy data only on occurance, not every char */
void _dump_string(pTHX_ perl_scalar* scalar_string){

    char*   src_buffer = get_scalar_string(scalar_string);
    size_t  src_length = get_scalar_string_length(scalar_string);
    U32     is_utf8 = is_scalar_utf8(scalar_string);

    if( is_utf8 )
    {
        printf("Utf flag is on\n");
    }
    else
    {
        printf("Utf flag is off\n");
    }
    
    printf( "String length is %u\n", src_length );
    
    size_t  src_offset = 0;
    
    while( src_offset < src_length ){
        unsigned char current_char = *(src_buffer + src_offset);

        printf( "Character: %u %x\n", (unsigned int)current_char, (unsigned int)current_char);
        
        src_offset++;
    }
}

