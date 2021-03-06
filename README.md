# NAME

Net::Kubernetes - An object oriented interface to the REST API's provided by kubernetes

[![Build Status](https://travis-ci.org/cavemanpi/net-kubernetes.png?branch=master)](https://travis-ci.org/cavemanpi/net-kubernetes)

# VERSION

version 1.08

# SYNOPSIS

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

<div>
    <h2>Build Status</h2>

    <img src="https://travis-ci.org/perljedi/net-kubernetes.svg?branch=release-0.21" />
</div>

## new - Create a new $kube object

All parameters are optional and have some basic default values (where appropriate).

- url \['http://localhost:8080'\]

    The base url for the kubernetes. This should include the protocal (http or https) but not "/api/v1beta3" (see base\_path).

- base\_path \['/api/v1beta3'\]

    The entry point for api calls, this may be used to set the api version with which to interact.

- username

    Username to use with basic authentication. If either username or password are not provided, basic authentication will not
    be used.

- password

    Password to use with basic authentication. If either username or password are not provided, basic authentication will not
    be used.

- token

    An authentication token to be used to access the apiserver.  This may be provided as a plain string, a path to a file
    from which to read the token (like /var/run/secrets/kubernetes.io/serviceaccount/token from within a pod), or a reference
    to a file handle (from which to read the token).

- ssl\_cert\_file, ssl\_key\_file, ssl\_ca\_file

    This there options passed into new will cause Net::Kubernetes in inlcude SSL client certs to requests to the kuberernetes
    API server for authentication.  There are basically just a passthrough to the underlying LWP::UserAgent used to handle the
    api requests.

- server\_version

    This module attempts to make some decisions on how it talks to kubernetes based upon the version of kubernetes it connects to.
    If this is not passed in, the first call to kubernetes will attempt to retrieve server version information from the server.

## get\_namespace("myNamespace");

This method returns a "Namespace" object on which many methods can be called implicitly
limited to the specified namespace.

## get\_pod('my-pod-name')

Delegates automatically to [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace) via $self->get\_namespace('default')

## get\_repllcation\_controller('my-rc-name') (aliased as $ns->get\_rc('my-rc-name'))

Delegates automatically to [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace) via $self->get\_namespace('default')

## get\_service('my-servce-name')

Delegates automatically to [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace) via $self->get\_namespace('default')

## get\_secret('my-secret-name')

Delegates automatically to [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace) via $self->get\_namespace('default')

## list\_nodes(\[label=>{label=>value}\], \[fields=>{field=>value}\])

returns a list of [Net::Kubernetes::Resource::Node](https://metacpan.org/pod/Net::Kubernetes::Resource::Node)s

# AUTHOR

Dave Mueller <dave@perljedi.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Liquid Web Inc.

This is free software, licensed under:

    The MIT (X11) License

# SEE ALSO

Please see those modules/websites for more information related to this module.

- [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace)
- [Net::Kubernetes::Resource](https://metacpan.org/pod/Net::Kubernetes::Resource)

# CONSUMES

- [Net::Kubernetes::Role::APIAccess](https://metacpan.org/pod/Net::Kubernetes::Role::APIAccess)
- [Net::Kubernetes::Role::ResourceCatalog](https://metacpan.org/pod/Net::Kubernetes::Role::ResourceCatalog)
- [Net::Kubernetes::Role::ResourceFactory](https://metacpan.org/pod/Net::Kubernetes::Role::ResourceFactory)
- [Net::Kubernetes::Role::ResourceFetcher](https://metacpan.org/pod/Net::Kubernetes::Role::ResourceFetcher)

# CONTRIBUTORS

- Chris Reinhardt <creinhardt@liquidweb.com>
- Christopher Pruden <cdpruden@liquidweb.com>
- Dave <dave@perljedi.com>
- Dave Mueller <dmueller@liquidweb.com>
- Kevin <kcavemanj@gmail.com>
- Kevin Johnson <kcavemanj@gmail.com>
