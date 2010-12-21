use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd escape/;
use Carp ();
use Test::More;
use Test::Exception;
use Test::Groonga;

BEGIN { use_ok 'Groonga::Client' }

my ($server, $client) = prepare();

subtest 'create table' => sub {

    note "Here are ways to create table and show created table."
      . " Make sure this table has _id and _key columns.";

    test_cmd($client, 'table_create --name Site --flags TABLE_HASH_KEY --key_type ShortText');
    test_cmd($client, 'select --table Site' );

};

subtest 'add columns' => sub {
    
    note "Here are ways to add columns."
      . " Please Remember this columns is SCALAR type.";

    test_cmd( $client, "column_create --table Site --name title --flags COLUMN_SCALAR --type ShortText");
    test_cmd( $client, "select --table Site" );

};

subtest 'create vocabulary table for full-text search' => sub {

    note "TABLE_PAT_KEY means store primary key into 'Patricia tree'."
      . " KEY_NORMALIZE means normalize the key vocab."
      . " TokenBigram is always known as 'N-gram'";

    test_cmd($client, 'table_create --name Terms --flags "TABLE_PAT_KEY|KEY_NORMALIZE" --key_type ShortText --default_tokenizer TokenBigram');
    test_cmd( $client, "select --table Terms" );

};

subtest 'create index column for full-text search' => sub {
    test_cmd($client, 'column_create --table Terms --name blog_title --flags "COLUMN_INDEX|WITH_POSITION" --type Site --source title');
    test_cmd( $client, "select --table Terms" );
};

subtest 'store data into table' => sub {
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
    
    note "If use groonga in interactive mode, you don't escape quote and white space.";
    my $escaped_json = escape($json);    
    
    test_cmd($client, "load --table Site $escaped_json");
    test_cmd($client, "select --table Site" );
};

subtest 'searching data' => sub {
    note "Here is way to search record that contain 'this' in title column.";
    test_cmd($client, 'select --table Site --query title:@this');
};

subtest 'specify output' => sub {
    test_cmd($client, 'select --table Site --output_columns _key,title,_score --query title:@test');
};

subtest 'limit' => sub {
    test_cmd($client, 'select --table Site --offset 0 --limit 3' );
    test_cmd($client, 'select --table Site --offset 3 --limit 3' );
    test_cmd($client, 'select --table Site --offset 7 --limit 3' );
};

subtest 'sort' => sub {
    test_cmd($client, 'select --table Site --sortby -_id' );
    test_cmd($client, 'select --table Site --query title:@test --output_columns _id,_score,title --sortby _score' );
    test_cmd($client, 'select --table Site --query title:@test --output_columns _id,_score,title --sortby _score,_id' );

};

undef $server;

done_testing();

