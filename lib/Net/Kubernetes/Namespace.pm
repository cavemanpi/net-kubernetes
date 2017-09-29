package Net::Kubernetes::Namespace;

# ABSTRACT: Provides access to kubernetes respources within a single namespace.

use Moose;
use MooseX::Aliases;
use syntax 'try';

has namespace => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has _namespace_data => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 0,
);

with 'Net::Kubernetes::Role::APIAccess';
with 'Net::Kubernetes::Role::ResourceLister';
with 'Net::Kubernetes::Role::ResourceCreator';
with 'Net::Kubernetes::Role::ResourceFactory';
with 'Net::Kubernetes::Role::ResourceFetcher';
with 'Net::Kubernetes::Role::SecretBuilder';

=head2 $ns->get_pod('my-pod-name')

=head2 $ns->get_repllcation_controller('my-rc-name') (aliased as $ns->get_rc('my-rc-name'))

=head2 $ns->get_service('my-servce-name')

=head2 $ns->get_secret('my-secret-name')

=head2 $ns->get_deployment('my-deployment-name')

=cut

sub get_secret {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'secret');
}

sub get_pod {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'pod');
}

sub get_service {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'service');
}

sub get_replication_controller {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'replicationcontroller');
}
alias get_rc => 'get_replication_controller';

sub get_deployment {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'deployment');
}

sub get_replica_set {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'replicaset');
}
alias get_rs => 'get_replica_set';

sub get_role {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'role');
}

sub get_role_binding {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'rolebinding');
}

sub get_service_account{
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'serviceaccount');
}

sub delete {
    my ($self) = @_;
    my ($res) = $self->ua->request($self->create_request(DELETE => $self->path));
    if ($res->is_success) {
        return 1;
    }
    return 0;
}

return 42;
