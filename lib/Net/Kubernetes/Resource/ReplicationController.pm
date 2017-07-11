package Net::Kubernetes::Resource::ReplicationController;
# ABSTRACT: Object representatioon of a Kubernetes Replication Controller

use Moose;
use URI;
use Time::HiRes;


extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';


=method my(@pods) = $rc->get_pods()

Fetch a list off all pods belonging to this replication controller.

=mehtod $rc->scale($replicas[, $timeout]);

Scales the replication controller to the requested number of replicas. This
method will poll waiting for the replicas to reach the requested value for the
duration specified by $timeout in seconds. 

On success, the string "scaled" is returned. 
On a timeout, 0 is returned.

If $timeout is -1, then the method will wait indefinitely.

A default scale timeout can be specified by passing scale_timeout
to the constructor.

=cut

sub scale {
    my($self, $replicas, $timeout) = @_;
    $timeout //= $self->scale_timeout;
    $self->spec->{replicas} = $replicas;
    $self->update;
    my $st = time;
    while($timeout < 0 || (time - $st) < $timeout){
        my $pods = $self->get_pods;
        if(scalar(@$pods) == $replicas){
            return "scaled";
        }
        sleep(0.3);
    }
    return 0;
}

return 42;
