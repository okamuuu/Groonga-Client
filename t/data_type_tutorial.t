use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd/;
use Carp ();
use Test::More;
use Test::Exception;
use Test::Groonga;

BEGIN { use_ok 'Groonga::Client' }

my ($server, $client) = prepare();

subtest 'Various data types' => sub {

    note "Groonga can store date in columns."
      . " the data are numerical value, the character string, time, and latitude and longitude, etc.";

    test_cmd($client, 'table_create --name Type --flags TABLE_HASH_KEY --key_type ShortText');
    test_cmd($client, 'column_create --table Type --name number --type Int32');
    test_cmd($client, 'column_create --table Type --name float --type Float');
    test_cmd($client, 'column_create --table Type --name string --type ShortText');
    test_cmd($client, 'column_create --table Type --name time --type Time');

    my $json = '[{"_key":"sample","number":"12345","float":"42.195","string":"GROONGA","time":"1234567890.12"}]';

    test_cmd($client, "load --table Type $json");
    test_cmd($client, "select --table Type");
};


subtest 'table type' => sub {

    note "In groonga we can use table as a type of the column."
      . " Then you have to store value of _key column.";

    test_cmd($client, "table_create --name Site --flags TABLE_HASH_KEY --key_type ShortText");
    test_cmd($client, "column_create --table Site --name title --flags COLUMN_SCALAR --type ShortText" );
    test_cmd($client, 'column_create --table Site --name link --type Site');        

    my $json = '[{"_key":"http://example.org/","title":"this","link":"http://example.net/"}]';
 
    test_cmd($client, "load --table Site $json");
    test_cmd($client, 'select --table Site --output_columns _key,title,link._key,link.title --query title:@this'); 

};

subtest 'vector column' => sub {

    note "Here is way to create column has many relationship.";

    ### this case, create column named links. not link.
    test_cmd($client, 'column_create --table Site --name links --flags COLUMN_VECTOR --type Site');

    my $json = '[{"_key":"http://example.org/","title":"this","links":["http://example.net/","http://example.org/","http://example.com/"]}]';

    test_cmd($client, "load --table Site $json");
    test_cmd($client, 'select --table Site --output_columns _key,title,links._key,links.title --query title:@this');   
};

undef $server;

done_testing;
