use strict;
use warnings;
use t::TestUtils qw/prepare test_cmd/;
use JSON ();
use Carp (); 
use Data::Dumper;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'Groonga::Client' }

subtest 'fixed?: 0 is interpreted as true for boolean typed value in grn_load()' => sub {

    # SEE ALSO: http://redmine.groonga.org/issues/304

    my ($server, $client) = prepare();

    test_cmd($client, "table_create BoolTest 0 ShortText");
    test_cmd($client, "column_create BoolTest val 0 Bool");
    test_cmd($client, 'load --table BoolTest --input_type json --output_type json --values [{\"_key\":\"test1\",\"val\":\"false\"},{\"_key\":\"test2\",\"val\":false},{\"_key\":\"test3\",\"val\":0}]');
    
    my $json = $client->cmd('select BoolTest'); 
    my $data = JSON::decode_json($json);
    
    is ($data->[1]->[0]->[2]->[2], 'true', 'text "false" is true.'); 
    is ($data->[1]->[0]->[3]->[2], 'false', 'boolean false is false'); 
    is ($data->[1]->[0]->[4]->[2], 'false', '0 is false.');
 
    $server->stop;
};


done_testing();

