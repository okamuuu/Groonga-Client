use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd escape/;
use Carp ();
use Test::More;
use Test::Exception;
use Test::Groonga;

BEGIN { use_ok 'Groonga::Client' }

my ($server, $client) = prepare();

subtest 'like JavaScript' => sub {

    test_cmd($client, "table_create --name Site --flags TABLE_HASH_KEY --key_type ShortText" );    
    test_cmd($client, "column_create --table Site --name title --flags COLUMN_SCALAR --type ShortText" );
    test_cmd($client, "select --table Site" );
    test_cmd($client, 'table_create --name Terms --flags "TABLE_PAT_KEY|KEY_NORMALIZE" --key_type ShortText --default_tokenizer TokenBigram');
    test_cmd($client, 'column_create --table Terms --name blog_title --flags "COLUMN_INDEX|WITH_POSITION" --type Site --source title');

    my $json = << "END_OF";
[
{"_key":"http://example.org/","title":"This is test record 1!"},
{"_key":"http://example.net/","title":"test record 2."},
{"_key":"http://example.com/","title":"test test record three."},
{"_key":"http://example.net/afr","title":"test record four."},
{"_key":"http://example.org/aba","title":"test test test record five."},
{"_key":"http://example.com/rab","title":"test test test test record six."},
{"_key":"http://example.net/atv","title":"test test test record seven."},
{"_key":"http://example.org/gat","title":"test test record eight."},
{"_key":"http://example.com/vdw","title":"test test record nine."},
]
END_OF

    my $escaped = escape($json);

    test_cmd($client, "load --table Site $escaped");
    test_cmd($client, 'select --table Site');
    test_cmd($client, 'select --table Site --filter "_id<=1" --output_columns _id,_key');
    test_cmd($client, 'select --table Site --filter "_id>=4\ &&\ _id<=6" --output_columns _id,_key');
    test_cmd($client, 'select --table Site --filter "_id\ <=\ 2\ ||\ _id\ >=\ 7" --output_columns _id,_key');
};

subtest 'sort by score' => sub {

        test_cmd( $client,
'select --table Site --filter "1" --scorer "_score=rand()" --output_columns _id,_key,_score --sortby _score'
        );
        test_cmd( $client,
'select --table Site --filter "1" --scorer "_score=rand()" --output_columns _id,_key,_score --sortby _score'
        );
};

subtest 'location' => sub {

    test_cmd( $client,
        "column_create --table Site --name location --type WGS84GeoPoint" );

    my $json = << "END_OF";
[
 {"_key":"http://example.org/","location":"128452975x503157902"}
 {"_key":"http://example.net/","location":"128487316x502920929"},
]
END_OF

    my $escaped = escape($json);
    test_cmd( $client, "load --table Site $escaped" );
    test_cmd( $client,
'select --table Site --query "_id:1\ OR\ _id:2" --output_columns _key,location'
    );

    test_cmd( $client,
'select --table Site --query "_id:1\ OR\ _id:2" --output_columns _key,location,_score --scorer "_score=geo_distance(location,\"128515259x503187188\")"'
    );

    test_cmd( $client,
'select --table Site --query "_id:1\ OR\ _id:2" --output_columns _key,location,_score --scorer "_score=geo_distance(location,\"128515259x503187188\")"'
    );
    test_cmd( $client,
'select --table Site --output_columns _key,location --filter "geo_in_circle(location, \"128515261x503187190\", 5000)"'
    );
};

$server->stop;

done_testing;

