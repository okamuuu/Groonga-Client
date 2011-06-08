use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd/;
use JSON ();
use Carp (); 
use Data::Dumper;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'Groonga::Client' }

subtest 'testing load option "ifexists"' => sub {

    # SEE ALSO: http://groonga.org/docs/commands/load.html

    my ($server, $client) = prepare();

    subtest 'prepare' => sub {
        test_cmd( $client, "table_create Site TABLE_HASH_KEY ShortText" );
        test_cmd( $client, "column_create Site title COLUMN_SCALAR ShortText" );
        test_cmd( $client,
'load --table Site --values [{\"_key\":\"001\",\"title\":\"test1\"}]'
        );

        my $json = $client->cmd('select --table Site');
        my $data = JSON::decode_json($json);

        is_deeply( $data->[1]->[0]->[2], [ '1', '001', 'test1' ], 'We are all set.');
    };

    subtest 'ifexists is true' => sub {
        test_cmd( $client,
'load --table Site --values [{\"_key\":\"001\",\"title\":\"test?\"}]'
        );

        my $json = $client->cmd('select --table Site');
        my $data = JSON::decode_json($json);

        is_deeply(
            $data->[1]->[0]->[2],
            [ '1', '001', 'test?' ],
            'So ifexists the key is true, it is overwritten'
        );
    };

    subtest 'ifexists is false' => sub {
        test_cmd( $client,
'load --table Site --ifexists false --values [{\"_key\":\"001\",\"title\":\"test!!!!!!!\"}]'
        );

        my $json = $client->cmd('select --table Site');
        my $data = JSON::decode_json($json);

        is_deeply(
            $data->[1]->[0]->[2],
            [ '1', '001', 'test?' ],
            'So ifexists the key is false, it is not overwritten'
        );
    };

    $server->stop;
};

done_testing();

