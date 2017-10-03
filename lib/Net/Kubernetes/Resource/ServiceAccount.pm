package Net::Kubernetes::Resource::ServiceAccount;

# ABSTRACT: Object representatioon of a Kubernetes service account

use Moose;

extends 'Net::Kubernetes::Resource';

has secrets => (
    is  => 'rw',
    isa => 'ArrayRef',
);

has imagePullSecrets => (
    is  => 'rw',
    isa => 'ArrayRef',
);

augment 'as_hashref' => sub {
	my $self = shift;

	return (
		secrets          => $self->secrets,
		imagePullSecrets => $self->imagePullSecrets,
	);
};

return 42;
