package Net::Kubernetes;

# ABSTRACT: An object oriented interface to the REST API's provided by kubernetes

use Moose;
require Net::Kubernetes::Namespace;
require LWP::UserAgent;
require HTTP::Request;
require URI;
require Throwable::Error;
use MIME::Base64;
require Net::Kubernetes::Exception;

=head1 SYNOPSIS

  my $kube = Net::Kubernetes->new(url=>'http://127.0.0.1:8080', username=>'dave', password=>'davespassword');

  # List methods will return either a list or an array reference.
  my $pod_list = $kube->list_pods();
  my @pods     = $kube->list_pods();

  my @rcs  = $kube->list_replication_controllers();
  my @rcs2 = $kube->list_rc();

  my @deployments  = $kube->list_deployments();

  my @replica_sets  = $keyb->list_replica_sets();
  my @replica_sets2 = $keyb->list_rs();

  my $nginx_pod = $kube->create_from_file('kubernetes/examples/pod.yaml');

  my $ns = $kube->get_namespace('default');

  # Namespaces contain all the list methods above as well.
  my $services = $ns->list_services;

  my $pod = $ns->get_pod('my-pod');

  $pod->delete;

  my $other_pod = $ns->create_from_file('./my-pod.yaml');

=begin html

<h2>Build Status</h2>

<img src="https://travis-ci.org/perljedi/net-kubernetes.svg?branch=release-0.21" />

=end html

=cut

with 'Net::Kubernetes::Role::APIAccess';
with 'Net::Kubernetes::Role::ResourceFetcher';
with 'Net::Kubernetes::Role::ResourceCatalog';

=head2 new - Create a new $kube object

All parameters are optional and have some basic default values (where appropriate).

=over 1

=item url ['http://localhost:8080']

The base url for the kubernetes. This should include the protocal (http or https) but not "/api/v1beta3" (see base_path).

=item base_path ['/api/v1beta3']

The entry point for api calls, this may be used to set the api version with which to interact.

=item username

Username to use with basic authentication. If either username or password are not provided, basic authentication will not
be used.

=item password

Password to use with basic authentication. If either username or password are not provided, basic authentication will not
be used.

=item token

An authentication token to be used to access the apiserver.  This may be provided as a plain string, a path to a file
from which to read the token (like /var/run/secrets/kubernetes.io/serviceaccount/token from within a pod), or a reference
to a file handle (from which to read the token).

=item ssl_cert_file, ssl_key_file, ssl_ca_file

This there options passed into new will cause Net::Kubernetes in inlcude SSL client certs to requests to the kuberernetes
API server for authentication.  There are basically just a passthrough to the underlying LWP::UserAgent used to handle the
api requests.

=item server_version

This module attempts to make some decisions on how it talks to kubernetes based upon the version of kubernetes it connects to.
If this is not passed in, the first call to kubernetes will attempt to retrieve server version information from the server.

=back

=head2 get_namespace("myNamespace");

This method returns a "Namespace" object on which many methods can be called implicitly
limited to the specified namespace.

=head2 get_pod('my-pod-name')

Delegates automatically to L<Net::Kubernetes::Namespace> via $self->get_namespace('default')

=head2 get_repllcation_controller('my-rc-name') (aliased as $ns->get_rc('my-rc-name'))

Delegates automatically to L<Net::Kubernetes::Namespace> via $self->get_namespace('default')

=head2 get_service('my-servce-name')

Delegates automatically to L<Net::Kubernetes::Namespace> via $self->get_namespace('default')

=head2 get_secret('my-secret-name')

Delegates automatically to L<Net::Kubernetes::Namespace> via $self->get_namespace('default')

=cut

has 'default_namespace' => (
    is       => 'rw',
    isa      => 'Net::Kubernetes::Namespace',
    required => 0,
    lazy     => 1,
    handles  => [
        qw(
            build_secret create create_from_file get_deployment get_pod
            get_rc get_replica_set get_replication_controller get_rs
            get_secret get_service list_deployments list_endpoints
            list_events list_pods list_rc list_replica_sets
            list_replication_controllers list_rs list_secrets list_services
            )
    ],
    builder => '_get_default_namespace',
);

sub get_namespace {
    my ($self, $namespace) = @_;
    if (!defined $namespace || !length $namespace) {
        Throwable::Error->throw(message => '$namespace cannot be null');
    }
    my $namespace_path = $self->base_path . "/namespaces/$namespace";
    my $res = $self->ua->request($self->create_request(GET => $self->url . $namespace_path));
    if ($res->is_success) {
        my $ns = $self->json->decode($res->content);

        # Somewhere between Kubernetes 1.2 and 1.5, the self link for namespaces broke. So for now, we can't trust them.
        # to populate the base_path. A bug report indicates that this bug is fixed in 1.7.
        # https://github.com/kubernetes/kubernetes/issues/48321
        my (%create_args) = (
            url             => $self->url,
            base_path       => $namespace_path,
            server_version  => $self->server_version,
            api_version     => $self->api_version,
            namespace       => $namespace,
            _namespace_data => $ns
        );
        $create_args{username}      = $self->username      if (defined $self->username);
        $create_args{password}      = $self->password      if (defined $self->password);
        $create_args{token}         = $self->token         if (defined $self->token);
        $create_args{ssl_cert_file} = $self->ssl_cert_file if (defined $self->ssl_cert_file);
        $create_args{ssl_key_file}  = $self->ssl_key_file  if (defined $self->ssl_key_file);
        $create_args{ssl_ca_file}   = $self->ssl_ca_file   if (defined $self->ssl_ca_file);
        $create_args{ssl_verify}    = $self->ssl_verify;
        return Net::Kubernetes::Namespace->new(%create_args);
    }
    else {
        Net::Kubernetes::Exception->throw(
            code    => $res->code,
            message => "Error getting namespace $namespace:\n" . $res->message
        );
    }
}

sub create_namespace {
    my ($self, $namespace) = @_;

    if (!defined $namespace || !length $namespace) {
        Throwable::Error->throw(message => '$namespace cannot be null');
    }

    my $namespace_path = $self->get_resource_path('namespace');
    my $res = $self->ua->request($self->create_request(
        POST => $namespace_path, 
        undef, $self->json->encode({ 
            metadata => {
                name => $namespace
            }
        })
    ));

    if ($res->is_success) {
        my $ns = $self->json->decode($res->content);

        # Somewhere between Kubernetes 1.2 and 1.5, the self link for namespaces broke. So for now, we can't trust them.
        # to populate the base_path. A bug report indicates that this bug is fixed in 1.7.
        # https://github.com/kubernetes/kubernetes/issues/48321
        $namespace_path .= "/$namespace";
	
        my (%create_args) = (
            url             => $self->url,
            base_path       => $namespace_path,
            server_version  => $self->server_version,
            api_version     => $self->api_version,
            namespace       => $namespace,
            _namespace_data => $ns
        );
        $create_args{username}      = $self->username      if (defined $self->username);
        $create_args{password}      = $self->password      if (defined $self->password);
        $create_args{token}         = $self->token         if (defined $self->token);
        $create_args{ssl_cert_file} = $self->ssl_cert_file if (defined $self->ssl_cert_file);
        $create_args{ssl_key_file}  = $self->ssl_key_file  if (defined $self->ssl_key_file);
        $create_args{ssl_ca_file}   = $self->ssl_ca_file   if (defined $self->ssl_ca_file);
        $create_args{ssl_verify}    = $self->ssl_verify;
        return Net::Kubernetes::Namespace->new(%create_args);
    }
    else {
        Net::Kubernetes::Exception->throw(
            code    => $res->code,
            message => "Error creating namespace $namespace:\n" . $res->message
        );
    }

}

=head2 list_nodes([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Node>s

=cut

sub list_nodes {
    my $self = shift;
    my (%options);
    if (ref($_[0])) {
        %options = %{$_[0]};
    }
    else {
        %options = @_;
    }

    my $uri = URI->new($self->path . '/nodes');
    my (%form) = ();
    $form{labelSelector} = $self->build_selector_from_hash($options{labels}) if (exists $options{labels});
    $form{fieldSelector} = $self->build_selector_from_hash($options{fields}) if (exists $options{fields});
    $uri->query_form(%form);

    my $res = $self->ua->request($self->create_request(GET => $uri));
    if ($res->is_success) {
        my $node_list = $self->json->decode($res->content);
        my (@nodes) = ();
        foreach my $node (@{$node_list->{items}}) {
            $node->{apiVersion} = $node_list->{apiVersion};
            push @nodes, $self->create_resource_object($node, 'Node');
        }
        return wantarray ? @nodes : \@nodes;
    }
    else {
        Net::Kubernetes::Exception->throw(
            code    => $res->code,
            message => $res->message
        );
    }
}

sub get_node {
    my ($self, $name) = @_;
    Net::Kubernetes::Exception->throw(message => "Missing required parameter 'name'") if (!defined $name || !length $name);
    return $self->get_resource_by_name($name, 'node');
}

=head2 list_service_accounts([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Service>s

=cut

sub list_service_accounts {
    my $self = shift;
    my (%options);
    if (ref($_[0])) {
        %options = %{$_[0]};
    }
    else {
        %options = @_;
    }

    my $uri = URI->new($self->path . '/serviceaccounts');
    my (%form) = ();
    $form{labelSelector} = $self->build_selector_from_hash($options{labels}) if (exists $options{labels});
    $form{fieldSelector} = $self->build_selector_from_hash($options{fields}) if (exists $options{fields});
    $uri->query_form(%form);

    my $res = $self->ua->request($self->create_request(GET => $uri));
    if ($res->is_success) {
        my $sa_list = $self->json->decode($res->content);
        my (@saccs) = ();
        foreach my $sacc (@{$sa_list->{items}}) {
            $sacc->{apiVersion} = $sa_list->{apiVersion};
            push @saccs, $self->create_resource_object($sacc, 'ServiceAccount');
        }
        return wantarray ? @saccs : \@saccs;
    }
    else {
        Net::Kubernetes::Exception->throw(
            code    => $res->code,
            message => $res->message
        );
    }
}

sub _get_default_namespace {
    my ($self) = @_;
    return $self->get_namespace('default');
}

# SEEALSO: Net::Kubernetes::Namespace, Net::Kubernetes::Resource

return 42;
