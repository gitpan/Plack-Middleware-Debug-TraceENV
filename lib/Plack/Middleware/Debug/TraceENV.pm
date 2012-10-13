package Plack::Middleware::Debug::TraceENV;
use strict;
use warnings;
use parent qw/Plack::Middleware::Debug::Base/;
our $VERSION = '0.02';

sub prepare_app {
    tie %ENV, 'Plack::Middleware::Debug::TraceENV';
}

my @TRACE;
my %COUNT;
sub run {
    my($self, $env, $panel) = @_;

    @TRACE = ();
    %COUNT = ();

    return sub {
        $panel->title('%ENV Tracer');
        $panel->nav_subtitle(
            sprintf(
                "F:%d, S:%d, E:%d, D:%d",
                $COUNT{FETCH}  || 0,
                $COUNT{STORE}  || 0,
                $COUNT{EXISTS} || 0,
                $COUNT{DELETE} || 0,
            )
        );
        $panel->content(
            $self->render_list_pairs(\@TRACE),
        );
    };
}

sub TIEHASH {
    return bless +{ %ENV }, shift;
}

sub FETCH {
    _tracer('FETCH', $_[1], undef,  caller() );
    $_[0]->{$_[1]};
}

sub STORE {
    _tracer('STORE', $_[1], $_[2],  caller() );
    $_[0]->{$_[1]} = $_[2];
}

sub EXISTS {
    _tracer('EXISTS', $_[1], undef,  caller() );
    return exists($_[0]->{$_[1]});
}

sub DELETE {
    _tracer('DELETE', $_[1], undef,  caller() );
    delete $_[0]->{$_[1]};
}

sub CLEAR {
    _tracer('CLEAR', undef, undef,  caller() );
    %{$_[0]} = ();
}

sub SCALAR {
    _tracer('SCALAR', undef, undef,  caller() );
    scalar %{$_[0]};
}

sub FIRSTKEY {
    _tracer('FIRSTKEY', undef, undef,  caller() );
    my $a = scalar keys %{$_[0]};
    each %{$_[0]};
}

sub NEXTKEY {
    _tracer('NEXTKEY', undef, undef,  caller() );
    each %{$_[0]};
}

sub _tracer {
    my ($method, $key, $value,
            $package, $filename, $line) = @_;
    $key = '' if !defined $key;
    $key = "$key=$value" if defined $value;
    push @TRACE, "$$: $method" => "$key [$filename#$line]";
    $COUNT{$method}++;
}

1;

__END__

=head1 NAME

Plack::Middleware::Debug::TraceENV - debug panel for tracing %ENV


=head1 SYNOPSIS

    use Plack::Builder;
    builder {
      enable 'Debug::TraceENV';
      $app;
    };


=head1 DESCRIPTION

Plack::Middleware::Debug::TraceENV is debug panel for watching %ENV.


=head1 METHOD

=over

=item prepare_app

see L<Plack::Middleware::Debug>

=item run

see L<Plack::Middleware::Debug::Base>

=back


=head1 REPOSITORY

Plack::Middleware::Debug::TraceENV is hosted on github
<http://github.com/bayashi/Plack-Middleware-Debug-TraceENV>


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO

L<Plack>, L<Plack::Middleware::Debug>


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
