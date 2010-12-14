package Groonga::Client;
use strict;
use warnings;
use Carp ();

use Class::Accessor::Lite ( ro => [qw/bin port host/ ] );

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;

    my $port = $args{port};
    my $host = $args{host};
    
    Carp::croak("missing mandatory parameter 'port'...") unless $port;
    Carp::croak("missing mandatory parameter 'host'...") unless $host;
    
    my $bin = `which groonga 2> /dev/null`;
    
    Carp::croak("not found cmd 'groonga'...") unless $bin;

    chomp($bin);

    return bless {
        bin   => $bin,
        port  => $port,
        host  => $host,
    }, $class;
}

sub cmd {
    my ( $self, $cmd ) = @_;

    Carp::croak("Not enough arguments...") unless $cmd;

    my $port = $self->port;
    my $host = $self->host;
    my $bin  = $self->bin;

    `$bin -p $port -c $host $cmd`; # return json 
}

1;

__END__

=head1 NAME

Groonga::Client -

=head1 SYNOPSIS

  use Groonga::Client;

=head1 DESCRIPTION

Groonga::Client is

=head1 AUTHOR

okamuuu E<lt>okamuuu@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
