package Net::Kubernetes::Resource::Role::HasPods;
# ABSTRACT: Resource role for types that may contain pods

use Moose::Role;

with 'Net::Kubernetes::Role::APIAccess';
with 'Net::Kubernetes::Role::ResourceCatalog';

requires 'namespace';

=method get_pods

retreive a list of pods associated with with respource (either ReplicationController or Service)

=cut

sub get_pods {
	my($self) = @_;
	my $uri = URI->new($self->get_resource_path('Pod'));
	$uri->query_form(labelSelector=>$self->build_selector_from_hash($self->spec->{selector}));
	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@pods)=();
		foreach my $pod (@{ $pod_list->{items}}){
			$pod->{apiVersion} = $pod_list->{apiVersion};
			my(%create_args) = %$pod;
			$create_args{api_version} = $pod->{apiVersion};
			$create_args{namespace} = $self->namespace;
			$create_args{username} = $self->username if($self->username);
			$create_args{password} = $self->password if($self->password);
			$create_args{url} = $self->url;
			$create_args{base_path} = $pod->{metadata}{selfLink};
			$create_args{ssl_cert_file} = $self->ssl_cert_file if($self->ssl_cert_file);
			$create_args{ssl_key_file} = $self->ssl_key_file if($self->ssl_key_file);
			$create_args{ssl_ca_file} = $self->ssl_ca_file if($self->ssl_ca_file);
			push @pods, Net::Kubernetes::Resource::Pod->new(%create_args);
		}
		return wantarray ? @pods : \@pods;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

return 42;
