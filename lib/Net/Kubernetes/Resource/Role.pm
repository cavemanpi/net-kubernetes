package Net::Kubernetes::Resource::Role;

use Moose;

extends 'Net::Kubernetes::Resource';

has rules => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 1,
);

augment 'as_hashref' => sub {
    my $self = shift;
    return ( rules => $self->rules );
};

return 1;
