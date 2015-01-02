#!/usr/bin/perl -I./lib/

use Test::Harness;

runtests(
    't/context.t',
    't/loader.t',
    't/template.t',
    't/expression.t',
    't/expression/in.t',
    't/filter/join.t',
    't/filter/add.t',
    't/tag/for.t',
    't/tag/include.t',
    't/tag/if.t',
);