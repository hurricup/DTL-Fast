#!/bin/bash

perl -e 'print "=================== Testing in $^V\n";' && cpanm Date::Format URI::Escape::XS && perl Makefile.PL && make && make test



