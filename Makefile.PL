require 5.006;
use inc::Module::Install;
all_from('lib/Metabase/Web.pm');

requires      ('Catalyst'                     => 5.80019 );
requires      ('Catalyst::Model::Adaptor'     => 0.08    );
requires      ('Catalyst::Plugin::ConfigLoader' => 0.27    );
requires      ('Catalyst::Plugin::Log::Dispatch' => 0.11    );
requires      ('Catalyst::Runtime'            => 5.80019 );
requires      ('Data::GUID'                   => 0.045   );
requires      ('Moose'                        => 0.99    );
requires      ('namespace::autoclean'         => 0.09    );

build_requires('Catalyst::Test'               => 0       );
build_requires('File::Temp'                   => 0.20    );
build_requires('JSON'                         => 2.17    );
build_requires('Metabase::Archive::SQLite'    => 0.003   );
build_requires('Metabase::Client::Simple'     => 0.003   );
build_requires('Metabase::Fact::String'       => 0.003   );
build_requires('Metabase::Gateway'            => 0       );
build_requires('Metabase::Index::FlatFile'    => 0.003   );
build_requires('Metabase::Librarian'          => 0.003   );
build_requires('Metabase::User::Profile'      => 0.003   );
build_requires('Metabase::User::Secret'       => 0.003   );
build_requires('MooseX::Types::Path::Class'   => 0.05    );
build_requires('Path::Class'                  => 0.17    );
build_requires('Test::More'                   => 0.88    );
build_requires('base'                         => 2.14    );
build_requires('perl'                         => 5.006   );

auto_manifest;
tests_recursive;

WriteAll;
