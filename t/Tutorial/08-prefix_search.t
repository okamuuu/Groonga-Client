use strict;
use warnings;
use t::TestUtils qw/groonga_bin prepare test_cmd escape/;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'Groonga::Client' }

my $bin = groonga_bin();

my ( $server, $client );

subtest 'prepare' => sub {
    plan skip_all => 'groonga binary is not found' unless $bin;
    ($server, $client) = prepare();
    isa_ok($server, 'Test::TCP');
    isa_ok($client, 'Groonga::Client');
};

subtest 'prifix search by primary key column named _key' => sub {
    plan skip_all => 'groonga binary is not found' unless $bin;

    test_cmd($client, 'table_create --name PatPre --flags TABLE_PAT_KEY --key_type ShortText');

    my $json = << "END_OF";
[
{"_key":"ひろゆき"},
{"_key":"まろゆき"},
{"_key":"ひろあき"},
]
END_OF

    my $escaped = escape($json);
    test_cmd($client, "load --table PatPre $escaped");
    test_cmd($client, 'select --table PatPre --query _key:@ひろ');
};

$server->stop;

done_testing();


