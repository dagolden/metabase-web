package Metabase::Web::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST' }

use Data::GUID;

__PACKAGE__->config(namespace => '');

our $VERSION = '0.003';
$VERSION = eval $VERSION;

# /submit/CPAN-Testers-Report
#  submit 0
sub submit : Chained('/') Args(1) ActionClass('REST') {
  my ($self, $c, $type) = @_;

  $c->stash->{type} = defined $type ? $type : q{};
}

sub submit_POST {
  my ($self, $c) = @_;

  my $fact_struct = $c->req->data;
  my ($type, $resource) = @{$fact_struct->{metadata}{core}}{qw/type resource/};
  unless ($c->stash->{type} eq $type ) {
    return $self->status_bad_request(
      $c,
      "URL and POST data types do not match"
    );
  }

  my ($user_guid, $user_secret) = $c->req->headers->authorization_basic;

  # XXX: In the future, this might be a queue id.  That might be a guid.  Time
  # will tell! -- rjbs, 2008-04-08
  my $guid = eval {
    $c->model('Metabase')->handle_submission(
      $fact_struct, $user_guid, $user_secret
    );
  };

  if ( $guid ) {
    $c->log->info("OK $type for $resource");
    return $self->status_created(
      $c,
      location => "/guid/$guid", 
      entity   => { guid => $guid },
    );
  }
  else {
    return $self->_gateway_error($c, $@)
  }

}

# /guid/cc3f4af4-0571-11dd-aa50-85a198b5225e
#  guid 0
sub guid : Chained('/') Args(1) ActionClass('REST') {
  my ($self, $c, $guid) = @_;

  if (my $guid = eval { Data::GUID->from_string($guid) }) {
    $c->stash->{guid} = $guid;
  }
}

sub guid_GET {
  my ($self, $c) = @_;

  return $self->status_bad_request($c, message => "invalid guid")
    unless my $guid = $c->stash->{guid};

  return $self->status_not_found($c, message => 'no such resource')
    unless my $fact = $c->model('Metabase')->public_librarian->extract($guid);

  return $self->status_ok(
    $c,
    entity => {
      fact => $fact->as_struct
    },
  );
}

# HEAD is just an "exists" check
sub guid_HEAD {
  my ($self, $c) = @_;

  return $self->status_bad_request($c, message => "invalid guid")
    unless my $guid = $c->stash->{guid};

  return $self->status_not_found($c, message => 'no such resource')
    unless my $fact = $c->model('Metabase')->public_librarian->exists($guid);

  return $self->status_ok( 
    $c,
    entity => { guid => $guid },
  );
}

# /register
#  
sub register : Chained('/') Args(0) ActionClass('REST') { } 

sub register_POST {
  my ($self, $c) = @_;
  my $list = $c->req->data;
  
  unless ( 
    $list && ref $list eq 'ARRAY' 
    && $list->[0]->{metadata}{core}{type} eq 'Metabase-User-Profile'
    && $list->[1]->{metadata}{core}{type} eq 'Metabase-User-Secret'
  ) {
    return $self->status_bad_request(
      $c,
      "invalid registration data"
    );
  }

  my $guid = eval {
    $c->model('Metabase')->handle_registration( @$list )
  };

  if ( $guid ) {
    $c->log->info("OK registered metabase:user:$guid");
    return $self->status_created(
      $c,
      location => "/guid/$guid", 
      entity   => { guid => $guid },
    );
  }
  else {
    return $self->_gateway_error($c, $@)
  }

}

sub _gateway_error {
  my ($self, $c, $error) = @_;
  if ( defined $error ) {
    chomp $error;
  }
  else {
    $error = '500: unknown error';
  }
  $c->log->error("gateway rejected fact: $error");
  my ($code, $reason) = $error =~ /\A([^:]+): (.+)/ms;
  $code   ||= 500;
  $reason ||= 'internal gateway error';
  $c->response->status($code);
  $c->stash->{rest} = { error => $reason };
  return;
}

# /search/.....
#sub search : Chained('/') CaptureArgs(0) {
#}
#
#sub simple : Chained('search') ActionClass('REST') {
#}
#
#sub simple_GET {
#  my ($self, $c, @args) = @_;
#
#  my $data = $c->model('Metabase')->public_liibrarian->search(@args);
#
#  return $self->status_ok(
#    $c,
#    entity => $data,
#  );
#}

__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

=over 

=item * David A. Golden (DAGOLDEN)

=item * Ricardo J. B. Signes (RJBS)

=back

=head1 COPYRIGHT AND LICENSE

  Portions Copyright (c) 2008-2010 by David A. Golden
  Portions Copyright (c) 2008-2009 by Ricardo J. B. Signes

Licensed under the same terms as Perl itself (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a
copy of the License from http://dev.perl.org/licenses/

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

1;
