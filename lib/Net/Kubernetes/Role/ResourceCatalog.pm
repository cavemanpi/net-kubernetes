package Net::Kubernetes::Role::ResourceCatalog;

use Moose::Role;

requires 'server_version';
requires 'url';

my %endpoint_catalog = (
	1.5 => {
		pod                   => 'api/v1',
		replicationcontroller => 'api/v1',
		service               => 'api/v1',
		event                 => 'api/v1',
		node                  => 'api/v1',
		serviceaccount        => 'api/v1',
		secret                => 'api/v1',
		endpoint              => 'api/v1',
		deployment            => 'apis/extensions/v1beta1',
	},
	1.6 => {
		pod                   => 'api/v1',
		replicationcontroller => 'api/v1',
		service               => 'api/v1',
		event                 => 'api/v1',
		node                  => 'api/v1',
		serviceaccount        => 'api/v1',
		secret                => 'api/v1',
		endpoint              => 'api/v1',
		deployment            => 'apis/apps/v1beta1',
	},
);

my %globals_catalog = (
	node            => 1,
	serviceaccount => 1,
);

=method resource_path($resource_name) 

Returns the full path of resources for the given version of kubernetes.

=cut

sub resource_path {
	my ($self, $resource) = @_;
	my $namespace      = $self->namespace;
	my $url            = $self->url;
	my $server_version = $self->server_version;

	$resource          = lc($resource);
	my $resource_api   = $endpoint_catalog{$server_version}{$resource} || 'api/v1';

	if ($self->global_resource($resource)) {
		return "$url/$resource_api/${resource}s";
	}
	
	return "$url/$resource_api/namespaces/$namespace/${resource}s";
}

=method global_resource

Returns a boolean indicating if the specified resource kind is a global within kubernetes.

=cut 

sub global_resource {
	my ($self, $resource) = @_;

	$resource = lc($resource);
	return $globals_catalog{$resource};
}

return 1;
