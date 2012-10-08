#!/usr/bin/env perl
use warnings;
use strict;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;
use Test::More;

{
    my $app = sub {

        $ENV{TEST_TRACE_ENV} = 1
            if !$ENV{TEST_TRACE_ENV} && !exists($ENV{TEST_TRACE_ENV});

        return [
            200,
            ['Content-Type' => 'text/html'],
            ['<html><body>fetch</body></html>']
        ];
    };

    $app = builder {
        enable 'Debug', panels => [qw/TraceENV/];
        $app;
    };

    test_psgi $app, sub {
        my $cb  = shift;
        my $res = $cb->(GET '/');

        is $res->code, 200, 'response status 200';

        like $res->content,
          qr/<a href="#" title="%ENV Tracer" class="plDebugTraceENV\d+Panel">/,
          "HTML contains TraceENV panel";

        like $res->content,
          qr{<small>F:\d+, S:\d+, E:\d+, D:\d+</small>},
          "counts on the Panel";

        like $res->content, qr{<td>\d+: FETCH</td>}, "label of FETCH";
        like $res->content, qr{<td>\d+: STORE</td>}, "label of STORE";
        like $res->content, qr{<td>\d+: EXISTS</td>}, "label of EXISTS";
        like $res->content,
          qr{<td>TEST_TRACE_ENV \[[^\]]+\]</td>},
          "Trace";
    };

}

done_testing;
