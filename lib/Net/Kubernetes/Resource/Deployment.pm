package Net::Kubernetes::Resource::Deployment;

use Moose;

extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';

sub scale {
    my($self, $replicas, $timeout) = @_;
    $timeout ||= 5;
    $self->spec->{replicas} = $replicas;
    $self->update;
    my $st = time;
    while((time - $st) < $timeout){
        my $pods = $self->get_pods;
        if(scalar(@$pods) == $replicas){
            return "scaled";
        }
        sleep(0.3);
    }
    return 0;
}

return 1;
