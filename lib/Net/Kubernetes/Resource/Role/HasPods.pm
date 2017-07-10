package Net::Kubernetes::Resource::Role::HasPods;
# ABSTRACT: Resource role for types that may contain pods

use Moose::Role;

with 'Net::Kubernetes::Role::APIAccess';

=method get_pods

retreive a list of pods associated with with respource (either ReplicationController or Service)

=cut

sub get_pods {
	my($self) = @_;
	my $uri = URI->new_abs("../pods", $self->path);
	$uri->query_form(labelSelector=>$self->_build_selector_from_hash($self->spec->{selector}));
	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@pods)=();
		foreach my $pod (@{ $pod_list->{items}}){
			$pod->{apiVersion} = $pod_list->{apiVersion};
			my(%create_args) = %$pod;
			$create_args{api_version} = $pod->{apiVersion};
			$create_args{username} = $self->username if($self->username);
			$create_args{password} = $self->password if($self->password);
			$create_args{url} = $self->url;
			$create_args{base_path} = $pod->{metadata}{selfLink};
			push @pods, Net::Kubernetes::Resource::Pod->new(%create_args);
		}
		return wantarray ? @pods : \@pods;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

sub _build_selector_from_hash {
	my($self, $select_hash) = @_;
	my(@selectors);

	my %labels;
	my @expressions;
	if (ref($select_hash->{matchLabels}) || ref($select_hash->{matchExpressions})) {
		if ($select_hash->{matchLabels}) {
			%labels = %{$select_hash->{matchLabels}};
		}

		if ($select_hash->{matchExpressions}) {
			@expressions = @{$select_hash->{matchExpressions}};
		}
	}
	else {
		%labels = %$select_hash;
	}

	foreach my $label (keys %labels){
		push @selectors, $label . '=' . $labels{$label};
	}
	foreach my $expression (@expressions) {
		my $operator = lc($expression->{operator});
		my $selector;
		if ($operator eq 'exists') {
			$selector = $expression->{key};
		}
		elsif ($operator eq 'doesnotexist') {
			$selector = "!$expression->{key}";
		}
		else {
			$selector = "$expression->{key} $operator (" . join(',', @{$expression->{values}}) . ")";
		}

		push @selectors, $selector;
	}

	return join(",", @selectors);
}

return 42;
