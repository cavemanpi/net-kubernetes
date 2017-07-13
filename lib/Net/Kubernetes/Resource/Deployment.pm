package Net::Kubernetes::Resource::Deployment;

use Moose;

extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';
with 'Net::Kubernetes::Resource::Role::HasReplicaSets';

=head2 my @pods = $deployment->get_pods()

Fetch a list of all pods belonging to this deployment.

=head2 my @sets = $deployment->get_rs()

Fetch a list of all replica sets belonging to this deployment.

=head2 $deployment->scale($replicas[, $timeout]);

Scales the deployment to the requested number of replicas. This method will
poll waiting for the replicas to reach the requested value for the duration
specified by $timeout in seconds.

On success, the string "scaled" is returned.
On a timeout, 0 is returned.

If $timeout is -1, then the method will wait indefinitely.

A default scale timeout can be specified by passing scale_timeout
to the constructor.

=cut

sub scale {
    my ($self, $replicas, $timeout) = @_;
    $timeout //= $self->scale_timeout;
    $self->spec->{replicas} = $replicas;
    $self->update;
    my $st = time;
    while ($timeout < 0 || (time - $st) < $timeout) {
        my $pods = $self->get_pods;
        if (scalar(@$pods) == $replicas) {
            return "scaled";
        }
        sleep(0.3);
    }
    return 0;
}

return 1;
