use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd escape/;
use Carp ();
use Test::More;
use Test::Exception;

BEGIN { use_ok 'Groonga::Client' }

my ($server, $client) = prepare();

subtest 'drill down' => sub {

    test_cmd($client, "table_create --name Site --flags TABLE_HASH_KEY --key_type ShortText" );
    test_cmd($client, "table_create --name SiteDomain --flags TABLE_HASH_KEY --key_type ShortText" );
    test_cmd($client, "table_create --name SiteCountry --flags TABLE_HASH_KEY --key_type ShortText" );
    test_cmd($client, "column_create --table Site --name domain --flags COLUMN_SCALAR --type SiteDomain" );
    test_cmd($client, "column_create --table Site --name country --flags COLUMN_SCALAR --type SiteCountry" );

    my $json = << "END_OF";
[
{"_key":"http://example.org/","domain":".org","country":"japan"},
{"_key":"http://example.net/","domain":".net","country":"brazil"},
{"_key":"http://example.com/","domain":".com","country":"japan"},
{"_key":"http://example.net/afr","domain":".net","country":"usa"},
{"_key":"http://example.org/aba","domain":".org","country":"korea"},
{"_key":"http://example.com/rab","domain":".com","country":"china"},
{"_key":"http://example.net/atv","domain":".net","country":"china"},
{"_key":"http://example.org/gat","domain":".org","country":"usa"},
{"_key":"http://example.com/vdw","domain":".com","country":"japan"}
]
END_OF

    my $escaped = escape($json);
    test_cmd($client, "load --table Site $escaped");
    test_cmd($client, 'select --table Site --limit 0 --drilldown domain');
};

undef $server;

done_testing();


