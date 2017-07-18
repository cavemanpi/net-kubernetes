package Net::Kubernetes::Resource::Pod;

# ABSTRACT: Object representatioon of a Kubernetes Pod

use Moose;

extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';

=head2 logs([container=>'foo'])

This method will return the logs from STDERR on for containers in a pod.  If the pod has more than one container,
the container argument become manditory, however for single container pods it may be ommited.

=cut

sub logs {
    my ($self, %options) = @_;
    if (scalar(@{$self->spec->{containers}}) > 1 && !exists($options{container})) {
        Net::Kunbernetes::Exception::ClientException->throw(
            code    => 499,
            message => 'Must provide container to get logs from a multi-container pod'
        );
    }

    my $uri = URI->new($self->path . '/log');
    $uri->query_form(\%options);
    my $res = $self->ua->request($self->create_request(GET => $uri));
    if ($res->is_success) {
        return $res->content;
    }
}

return 42;
