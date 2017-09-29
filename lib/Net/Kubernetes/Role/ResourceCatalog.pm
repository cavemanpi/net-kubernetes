package Net::Kubernetes::Role::ResourceCatalog;

use Moose::Role;
use List::Util qw(max);

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
        namespace             => 'api/v1',
        secret                => 'api/v1',
        endpoint              => 'api/v1',
        deployment            => 'apis/extensions/v1beta1',
        replicaset            => 'apis/extensions/v1beta1',
        role                  => 'apis/rbac.authorization.k8s.io/v1alpha1',
        rolebinding           => 'apis/rbac.authorization.k8s.io/v1alpha1',
    }
);

$endpoint_catalog{'1.6'} = { 
    %{$endpoint_catalog{'1.5'}},
    deployment            => 'apis/apps/v1beta1',
    replicaset            => 'apis/extensions/v1beta1',
};

$endpoint_catalog{'1.7'} = {
    %{$endpoint_catalog{'1.6'}},
    role                  => 'apis/rbac.authorization.k8s.io/v1beta1',
    rolebinding           => 'apis/rbac.authorization.k8s.io/v1beta1',
};

my %globals_catalog = (
    node      => 1,
    namespace => 1,
);

=head2 resource_path($resource_name)

Returns the full path of resources for the given version of kubernetes.

=cut

sub get_resource_path {
    my ($self, $resource) = @_;
    my $url            = $self->url;
    my $server_version = $self->server_version;

    my $max_known_version = max(keys(%endpoint_catalog));
    if ($server_version > $max_known_version) {
        $server_version = $max_known_version;
    }

    $resource = lc($resource);
    my $resource_api = $endpoint_catalog{$server_version}{$resource} || 'api/v1';

    if ($self->is_global_resource($resource)) {
        return "$url/$resource_api/${resource}s";
    }

    my $namespace = $self->namespace;

    return "$url/$resource_api/namespaces/$namespace/${resource}s";
}

=head2 is_global_resource

Returns a boolean indicating if the specified resource kind is a global within kubernetes.

=cut

sub is_global_resource {
    my ($self, $resource) = @_;

    $resource = lc($resource);
    return $globals_catalog{$resource};
}

return 1;
