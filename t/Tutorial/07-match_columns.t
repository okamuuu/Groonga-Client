use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd escape/;
use Carp ();
use Test::More;
use Test::Exception;
use Test::Groonga;

BEGIN { use_ok 'Groonga::Client' }

my ($server, $client) = prepare();

subtest 'match columns' => sub {

    test_cmd($client, 'table_create --name Blog1 --flags TABLE_HASH_KEY --key_type ShortText');
    test_cmd($client, 'column_create --table Blog1 --name title --flags COLUMN_SCALAR --type ShortText');
    test_cmd($client, 'column_create --table Blog1 --name message --flags COLUMN_SCALAR --type ShortText');
    test_cmd($client, 'table_create --name IndexBlog1 --flags "TABLE_PAT_KEY|KEY_NORMALIZE" --key_type ShortText --default_tokenizer TokenBigram');
    test_cmd($client, 'column_create --table IndexBlog1 --name index_title --flags "COLUMN_INDEX|WITH_POSITION" --type Blog1 --source title');
    test_cmd($client, 'column_create --table IndexBlog1 --name index_message --flags "COLUMN_INDEX|WITH_POSITION" --type Blog1 --source message');

    my $json = << "END_OF";
[
{"_key":"grn1","title":"groonga test","message":"groonga message"},
{"_key":"grn2","title":"baseball result","message":"rakutan eggs 4 - 4 groonga moritars"},
{"_key":"grn3","title":"groonga message","message":"none"}
]
END_OF

    my $escaped = escape($json);
    test_cmd($client, "load --table Blog1 $escaped");
    test_cmd($client, 'select --table Blog1');
    test_cmd($client, 'select --table Blog1 --match_columns "title||message" --query groonga');
    test_cmd($client, 'select --table Blog1 --match_columns "title||message" --query message');
    test_cmd($client, 'select --table Blog1 --match_columns title --query message');
};

undef $server;

done_testing();


