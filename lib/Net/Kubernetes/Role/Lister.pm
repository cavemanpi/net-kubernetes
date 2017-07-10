package Net::Kubernetes::Role::Lister;

use Moose::Role;

=method build_selector_from_hash($key_value_pairs) 

Converts a hash of key value pairs to a selector string.

=cut

sub build_selector_from_hash {
	my($self, $select_hash) = @_;
	my(@selectors);
	foreach my $label (keys %{ $select_hash }){
		push @selectors, $label.'='.$select_hash->{$label};
	}
	return \@selectors;
}

1;
