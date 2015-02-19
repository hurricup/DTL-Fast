#define PERL_NO_GET_CONTEXT 

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "src/perl_mnemonic.h"
#include "src/spaceless.h"
#include "src/html_protect.h"

MODULE = DTL::Fast  PACKAGE = DTL::Fast

void
spaceless( SV* scalar_string )
    CODE:
        _spaceless( aTHX_ scalar_string );

void
html_protect( SV* scalar_string )
    CODE:
        _html_protect(aTHX_ scalar_string );
