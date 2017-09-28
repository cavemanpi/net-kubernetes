package Net::Kubernetes::Resource::RoleBinding;

use Moose;

extends 'Net::Kubernetes::Resource';

has roleRef => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
);

has subjects => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 1,
);

augment as_hashref => sub {
    my $self = shift;
    return (
        roleRef  => $self->roleRef,
	subjects => $self->subjects,
    );
};

return 1;
