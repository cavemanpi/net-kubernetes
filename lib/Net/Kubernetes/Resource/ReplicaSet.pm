package Net::Kubernetes::Resource::ReplicaSet;

use Moose;

extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';

return 1;
