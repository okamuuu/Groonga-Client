package t::TestUtils;
use strict;
use warnings;
use JSON qw/decode_json encode_json/;
use Test::More;
use Test::Groonga;
use Exporter 'import';
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Terse    = 1;

our @EXPORT = qw/prepare test_cmd escape/;

sub prepare {
    
    my $server = Test::Groonga->new();
    $server->start();

    my $client = Groonga::Client->new(
        port => $server->port,
        host => $server->host,
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

