package t::TestUtils;
use strict;
use warnings;
use JSON qw/decode_json/;
use Test::More;
use Test::Groonga;
use File::Which ();
use File::Temp ();
use Exporter 'import';

our @EXPORT = qw/prepare failed_cmd test_cmd/;

sub prepare {

    my $server = Test::Groonga->gqtp;
    
    my $client = Groonga::Client->new(
        port => $server->port,
        host => 'localhost',
    );

    return ($server, $client);
}

sub failed_cmd {
    my ($client, $cmd) = @_;

    my $json = $client->cmd($cmd);
    my $data = decode_json($json);
 
warn    my $status_code = $data->[0]->[0];

    note
        "cmd : $cmd\n"
    .   "this cmd will faile.";

    ok $status_code != 0;
}

sub test_cmd {
    my ($client, $cmd) = @_;

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

1;

