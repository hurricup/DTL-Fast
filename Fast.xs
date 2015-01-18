#define PERL_NO_GET_CONTEXT 

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "c/spaceless.h"

MODULE = DTL::Fast  PACKAGE = DTL::Fast

SV*
spaceless( SV* sv_string_ptr )
    CODE:
        _spaceless( aTHX_ sv_string_ptr );
