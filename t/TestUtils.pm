package t::TestUtils;
use strict;
use warnings;
use JSON qw/decode_json/;
use Test::More;
use Test::TCP;
use File::Which ();
use File::Temp ();
use Exporter 'import';

our @EXPORT = qw/prepare test_cmd escape/;

sub prepare {

    my $bin = scalar File::Which::which('groonga');
    plan skip_all => 'groonga binary is not found' unless defined $bin;

    my $db  = File::Temp::tmpnam();

    my $server = Test::TCP->new(
        code => sub {
            my $port = shift;

            # -s : server mode
            # -n : create new database
            exec $bin, '-s', '--port', $port, '-n', $db;
            die "cannot execute $bin: $!";
        },
    );

    my $client = Groonga::Client->new(
        port => $server->port,
        host => 'localhost',
    );

    return ($server, $client);
}

sub test_cmd {
    my ($client, $cmd, $expect) = @_;

    my $json = $client->cmd($cmd);
    my $data = decode_json($json);
 
    my $status_code = $data->[0]->[0];
    my $elapsed     = $data->[0]->[2];
    my $result      = $data->[1];

    note
        "cmd      : $cmd\n"
      . "elapsed  : $elapsed\n"
      . "get json : $json";

    is $status_code, 0;
}

sub escape {
    my $string = shift;
    $string =~ s/(['"\s])/\\$1/sg;
    return $string;
}

1;

