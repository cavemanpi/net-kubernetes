# NAME

Net::Kubernetes - An object oriented interface to the REST API's provided by kubernetes

[![Build Status](https://travis-ci.org/perljedi/net-kubernetes.png?branch=release-0.10)](https://travis-ci.org/perljedi/net-kubernetes)

# VERSION

version 0.10

# SYNOPSIS

    my $kube = Net::Kubernets->new(url=>'http://127.0.0.1:8080', username=>'dave', password=>'davespassword');
    my $pod_list = $kube->list_pods();
    
    my $nginx_pod = $kube->create_from_file('kubernetes/examples/pod.yaml');
    
    my $ns = $kube->get_namespace('default');
    
    my $services = $ns->list_services;
    
    my $pod = $ns->get_pod('my-pod');
    
    $pod->delete;
    
    my $other_pod = $ns->create_from_file('./my-pod.yaml');

# METHODS

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

## get\_namespace("myNamespace");

This method returns a "Namespace" object on which many methods can be called implicitly
limited to the specified namespace.

## list\_pods(\[label=>{label=>value}\], \[fields=>{field=>value}\])

returns a list of [Net::Kubernetes::Resource::Pod](https://metacpan.org/pod/Net::Kubernetes::Resource::Pod)s

## list\_rc(\[label=>{label=>value}\], \[fields=>{field=>value}\])

returns a list of [Net::Kubernetes::Resource::ReplicationController](https://metacpan.org/pod/Net::Kubernetes::Resource::ReplicationController)s

## list\_replication\_controllers(\[label=>{label=>value}\], \[fields=>{field=>value}\])

returns a list of [Net::Kubernetes::Resource::ReplicationController](https://metacpan.org/pod/Net::Kubernetes::Resource::ReplicationController)s

## list\_secrets(\[label=>{label=>value}\], \[fields=>{field=>value}\])

returns a list of [Net::Kubernetes::Resource::Secret](https://metacpan.org/pod/Net::Kubernetes::Resource::Secret)s

## list\_services(\[label=>{label=>value}\], \[fields=>{field=>value}\])

returns a list of [Net::Kubernetes::Resource::Service](https://metacpan.org/pod/Net::Kubernetes::Resource::Service)s

## create({OBJECT})

Creates a new [Net::Kubernetes::Resource](https://metacpan.org/pod/Net::Kubernetes::Resource) (subtype determined by $BNJECT->{kind})

## create\_from\_file(PATH\_TO\_FILE) (accepts either JSON or YAML files)

Create from file is really just a short cut around something like:

    my $object = YAML::LoadFile(PATH_TO_FILE);
    $kube->create($object);

## get\_pod('my-pod-name')

Delegates automatically to [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace) via $self->get\_namespace('default')

## get\_repllcation\_controller('my-rc-name') (aliased as $ns->get\_rc('my-rc-name'))

Delegates automatically to [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace) via $self->get\_namespace('default')

## get\_service('my-servce-name')

Delegates automatically to [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace) via $self->get\_namespace('default')

## get\_secret('my-secret-name')

Delegates automatically to [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace) via $self->get\_namespace('default')

<div>
    <h2>Build Status</h2>

    <img src="https://travis-ci.org/perljedi/net-kubernetes.svg?branch=release-0.10" />
</div>

# AUTHOR

Dave Mueller <dave@perljedi.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Dave Mueller.

This is free software, licensed under:

    The MIT (X11) License

# SEE ALSO

Please see those modules/websites for more information related to this module.

- [Net::Kubernetes::Namespace](https://metacpan.org/pod/Net::Kubernetes::Namespace)
- [Net::Kubernetes::Resource](https://metacpan.org/pod/Net::Kubernetes::Resource)
