package Net::Kubernetes::Resource::Role::HasReplicaSets;
# ABSTRACT: Resource role for types that may contain replica sets

use Moose::Role;

with 'Net::Kubernetes::Role::APIAccess';
with 'Net::Kubernetes::Role::ResourceCatalog';

requires 'namespace';

=method get_replica_sets

retreive a list of replica sets associated with with resource such as a Deployment

=cut

sub get_replica_sets {
	my($self) = @_;
	my $uri = URI->new($self->get_resource_path('ReplicaSet'));
	$uri->query_form(labelSelector=>$self->build_selector_from_hash($self->spec->{selector}));
	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $set_list = $self->json->decode($res->content);
		my @sets;
		foreach my $rs (@{ $set_list->{items}}){
			$rs->{apiVersion} = $set_list->{apiVersion};
			my(%create_args) = %$rs;
			$create_args{api_version} = $create_args{apiVersion};
			$create_args{namespace}   = $self->namespace;
			$create_args{username}    = $self->username if($self->username);
			$create_args{password}    = $self->password if($self->password);
			$create_args{url}         = $self->url;
			$create_args{base_path}   = $rs->{metadata}{selfLink};
			$create_args{ssl_cert_file} = $self->ssl_cert_file if($self->ssl_cert_file);
			$create_args{ssl_key_file} = $self->ssl_key_file if($self->ssl_key_file);
			$create_args{ssl_ca_file} = $self->ssl_ca_file if($self->ssl_ca_file);
			push @sets, Net::Kubernetes::Resource::ReplicaSet->new(%create_args);
		}
		return wantarray ? @sets : \@sets;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

return 1;
