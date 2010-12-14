use strict;
use warnings;
use Carp ();
use Test::More;
use Test::Exception;
use Test::Groonga;

BEGIN { use_ok 'Groonga::Client' }

use Data::Dumper;

my $server = Test::Groonga->new();
$server->start();

subtest 'cmd' => sub {

    my $client = Groonga::Client->new(
        port => $server->port,
        host => $server->host,
    );

    my $success = $client->cmd("table_create --name Site --flags TABLE_HASH_KEY --key_type ShortText");
    ok $success, "success result: $success";

    my $fail = $client->cmd("xxxxxxxxxxxxxxxxxxxxxxxxx");
    ok $fail, "fail result: $fail";
};


$server->stop();

done_testing();

