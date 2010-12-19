use inc::Module::Install;
name 'Groonga-Client';
all_from 'lib/Groonga/Client.pm';

requires 'Class::Accessor::Lite' => 0.05;
requires 'File::Which';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::TCP' => 1.09;
test_requires 'Test::More';
test_requires 'File::Temp';
auto_set_repository;
auto_include;
WriteAll;
