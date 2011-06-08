use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd/;
use Carp ();
use Test::More;
use Test::Exception;

BEGIN { use_ok 'Groonga::Client' }

subtest 'cmd' => sub {

    my ($server, $client) = prepare();

    test_cmd($client, "table_create --name Site --flags TABLE_HASH_KEY --key_type ShortText");
    
    $server->stop;
};


done_testing();

