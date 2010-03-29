use strict;
use warnings;
package Test::Metabase::Web::Config;

use File::Temp ();
use Path::Class;
use JSON;

# XXX: Part of a monstrous hack perpetrated here and in Model::Metabase.
my $CURRENT_GATEWAY;
sub gateway { $CURRENT_GATEWAY }

my $STORAGE_DIR;
sub storage_dir { $STORAGE_DIR };

sub import {
  my ($class, %opts) = @_;
  my %tmp;
  $STORAGE_DIR = dir(File::Temp::tempdir(CLEANUP => 1));

  my $config = {
    'Model::Metabase' => {
      class => 'Test::Metabase::Gateway',
      args => { data_dir => "$STORAGE_DIR", %opts },
    },
    'Log::Dispatch' => [ { 
	    class => 'Null',
	min_level => 'error',
    }],
  };

  my $config_file = dir($STORAGE_DIR)->file('test.json');

  open my $fh, '>', $config_file or die "can't write to $config_file: $!";
  print { $fh } JSON->new->ascii->encode($config);
  $ENV{METABASE_WEB_CONFIG} = $config_file;

  no warnings 'once';
  $Metabase::Web::Model::Metabase::COMPONENT_CALLBACK = sub {
    $CURRENT_GATEWAY = shift;
  };

  return;
}

1;
