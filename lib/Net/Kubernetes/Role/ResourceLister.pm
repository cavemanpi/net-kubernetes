package Net::Kubernetes::Role::ResourceLister;
# ABSTRACT: Role to give access to list_* methods.

use Moose::Role;
use MooseX::Aliases;
require Net::Kubernetes::Resource::Service;
require Net::Kubernetes::Resource::Pod;
require Net::Kubernetes::Resource::ReplicationController;

with 'Net::Kubernetes::Role::ResourceFactory';
with 'Net::Kubernetes::Role::ResourceCatalog';

requires 'ua';
requires 'create_request';
requires 'json';

=method list_pods([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Pod>s

=cut

sub list_pods {
	my $self = shift;
	return $self->_retrieve_list('Pod', @_);
}

=method list_rc([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::ReplicationController>s

=method list_replication_controllers([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::ReplicationController>s

=cut

sub list_replication_controllers {
	my $self = shift;
	return $self->_retrieve_list('ReplicationController', @_);
}

alias list_rc => 'list_replication_controllers';

=method list_services([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Service>s

=cut

sub list_services {
	my $self = shift;
	return $self->_retrieve_list('Service', @_);
}

=method list_events([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Event>s

=cut

sub list_events {
	my $self = shift;
	return $self->_retrieve_list('Event', @_);
}

=method list_secrets([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Secret>s

=cut

sub list_secrets {
	my $self = shift;
	return $self->_retrieve_list('Secret', @_);
}

=method list_endpoints([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Endpoint>s

=cut

sub list_endpoints {
	my $self = shift;
	return $self->_retrieve_list('Endpoint', @_);
}

=method list_deployments([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Deployment>s

=cut

sub list_deployments {
	my $self = shift;
	my %options = $self->_norm_options(@_);

	return $self->_retrieve_list('Deployment', %options);
}

=method list_replica_sets([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::ReplicaSet>s

=cut

=method list_rs([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::ReplicaSet>s

=cut

alias list_rs => 'list_replica_sets';

sub list_replica_sets {
	my $self = shift;
	my %options = $self->_norm_options(@_);

	return $self->_retrieve_list('ReplicaSet', %options);
}

sub _retrieve_list {
	my $self = shift;
	my $resource_kind = shift;
	my %options = $self->_norm_options(@_);

	my $uri = URI->new($self->get_resource_path($resource_kind));
	my(%form) = ();
	$form{labelSelector}=$self->build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);

	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $resource_list = $self->json->decode($res->content);

		my @resources;
		foreach my $resource (@{ $resource_list->{items}}){
			$resource->{apiVersion} = $resource_list->{apiVersion};
			push @resources, $self->create_resource_object($resource, $resource_kind);
		}

		return wantarray ? @resources : \@resources;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

sub _norm_options {
	my $self = shift;
	my %options;

	if (ref($_[0])) {
		%options = %{ $_[0] };
	}else{
		%options = @_;
	}

	return %options;
}

return 42;
