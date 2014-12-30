#!/usr/bin/perl -I./lib/

use Test::Harness;

runtests(
    't/context.t',
    't/loader.t',
    't/template.t',
    't/filter/join.t',
    't/filter/add.t',
    't/tag/include.t',
);