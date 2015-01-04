#!/usr/bin/perl -I./lib/

use Test::Harness;

runtests(
    't/context.t',
    't/expression.t',
    't/expression/in.t',
    't/expression/defined.t',
    't/loader.t',
    't/template.t',
    't/filter/add.t',
    't/filter/escape.t',
    't/filter/join.t',
    't/filter/reverse.t',
    't/filter/safe.t',
    't/tag/autoescape.t',
    't/tag/comment.t',
    't/tag/cycle.t',
    't/tag/debug.t',
    't/tag/filter.t',
    't/tag/for.t',
    't/tag/if.t',
    't/tag/include.t',
    't/tag/uncomment.t',
);