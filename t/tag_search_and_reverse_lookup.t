use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd escape/;
use Carp ();
use Test::More;
use Test::Exception;
use Test::Groonga;

BEGIN { use_ok 'Groonga::Client' }

my ($server, $client) = prepare();

subtest 'tag search' => sub {

    test_cmd($client, "table_create --name Video --flags TABLE_HASH_KEY --key_type UInt32" );
    test_cmd($client, "table_create --name Tag --flags TABLE_HASH_KEY --key_type ShortText");
    test_cmd($client, "column_create --table Video --name title --flags COLUMN_SCALAR --type ShortText" );
    test_cmd($client, "column_create --table Video --name tags --flags COLUMN_VECTOR --type Tag" );
    test_cmd($client, "column_create --table Tag --name index_tags --flags COLUMN_INDEX --type Video --source tags" );

    my $json = << "END_OF";
[
{"_key":1,"title":"Soccer 2010","tags":["Sports","Soccer"]},
{"_key":2,"title":"Zenigata Kinjirou","tags":["Variety","Money"]},
{"_key":3,"title":"groonga Demo","tags":["IT","Server","groonga"]},
{"_key":4,"title":"Moero!! Ultra Baseball","tags":["Sports","Baseball"]},
{"_key":5,"title":"Hex Gone!","tags":["Variety","Quiz"]},
{"_key":6,"title":"Pikonyan 1","tags":["Animation","Pikonyan"]},
{"_key":7,"title":"Draw 8 Month","tags":["Animation","Raccoon"]},
{"_key":8,"title":"K.O.","tags":["Animation","Music"]}
]
END_OF

    my $escaped = escape($json);
    test_cmd($client, "load --table Video $escaped");
    test_cmd($client, 'select --table Video --query tags:@Variety --output_columns _key,title');
    test_cmd($client, 'select --table Video --query tags:@Sports --output_columns _key,title');   
    test_cmd($client, 'select --table Video --query tags:@Animation --output_columns _key,title');

};

subtest 'reverse lookup' => sub {

    test_cmd($client, "table_create --name User --flags TABLE_HASH_KEY --key_type ShortText");
    test_cmd($client, "column_create --table User --name username --flags COLUMN_SCALAR --type ShortText");
    test_cmd($client, "column_create --table User --name friends --flags COLUMN_VECTOR --type User");
    test_cmd($client, "column_create --table User --name index_friends --flags COLUMN_INDEX --type User --source friends");

    my $json = << "END_OF";
[
{"_key":"ken","username":"ken","friends":["taro","jiro","tomo","moritapo"]},
{"_key":"taro","username":"taro","friends":["jiro","tomo"]},
{"_key":"jiro","username":"jiro","friends":["taro","tomo"]},
{"_key":"tomo","username":"tomo","friends":["ken","hana"]},
{"_key":"hana","username":"hana","friends":["ken","taro","jiro","moritapo","tomo"]},
]
END_OF

    my $escaped = escape($json);
    test_cmd($client, "load --table User $escaped");
    test_cmd($client, 'select --table User --query friends:@tomo --output_columns _key,username');
    test_cmd($client, 'select --table User --query friends:@jiro --output_columns _key,username');
    test_cmd($client, 'select --table User --limit 0 --drilldown friends');
};

undef $server;

done_testing();


