use strict;
use warnings;
use Test::Spec;
use HTTP::Request;
use HTTP::Response;
use Test::Deep;
use Test::Fatal qw(lives_ok dies_ok);
use Net::Kubernetes;
use Net::Kubernetes::Namespace;
use Test::Mock::Wrapper 0.18;
use vars qw($lwpMock $sut %config);

describe "Net::Kubernetes" => sub {
    before sub {
        $lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
        lives_ok {
            $sut = Net::Kubernetes->new(server_version => '1.5');
        }
    };
    spec_helper "resource_lister_examples.pl";
    it "can be instantiated" => sub {
        ok($sut);
        isa_ok($sut, 'Net::Kubernetes');
    };

    describe "resource list method" => sub {

        it "is delegated to the namespace object" => sub {
            $lwpMock->addMock('request')
                ->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "metadata":{"selfLink":"/path/to/me"}}'));

            foreach my $list_method (
                qw(list_rc list_pods list_replication_controllers list_services list_events list_secrets list_endpoints list_deployments list_service_accounts list_roles list_role_bindings)) {
                my $expectation = Net::Kubernetes::Namespace->expects($list_method);
                $sut->$list_method;
                $expectation->verify();
            }
        };
    };

    describe "get_namespace" => sub {
        it "can get a namespace" => sub {
            can_ok($sut, 'get_namespace');
        };
        it "throws an exception if namespace is not passed in" => sub {
            $lwpMock->addMock('request')
                ->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "metadata":{"selfLink":"/path/to/me"}}'));
            dies_ok {
                $sut->get_namespace;
            };
        };
        it "throws an exception if the call returns an error" => sub {
            $lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
            dies_ok {
                $sut->get_namespace('foo');
            };
        };
        it "doesn't throw an exception if the call succeeds" => sub {
            $lwpMock->addMock('request')
                ->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "metadata":{"selfLink":"/path/to/me"}}'));
            lives_ok {
                $sut->get_namespace('myNamespace');
            };
        };
        it "returns a new Net::Kubernetes::Namespace object set to the requested namespace" => sub {
            $lwpMock->addMock('request')
                ->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "metadata":{"selfLink":"/path/to/me"}}'));
            my $res = $sut->get_namespace('myNamespace');
            isa_ok($res, 'Net::Kubernetes::Namespace');
            is($res->namespace, 'myNamespace');
        };
    };
    describe "list_nodes" => sub {
        before sub {
            $config{method} = 'list_nodes';
        };
        it_should_behave_like "all_list_methods";
        it "returns a list of Net::Kubernetes::Node objects" => sub {
            $lwpMock->addMock('request')->returns(
                HTTP::Response->new(
                    200,
                    "ok",
                    undef,
'{ "kind": "NodeList", "apiVersion": "v1beta3", "metadata":{ "selfLink": "/api/v1beta3/nodes", "resourceVersion": "60116" }, "items": [ { "metadata": { "name": "name", "selfLink": "/api/v1beta3/nodes/name", "labels": { "kubernetes.io/hostname": "name" } }, "spec": { "externalID": "name" }, "status": { "field": "woot" } }] }'
                )
            );
            my (@nodes) = $sut->list_nodes();
            is(scalar(@nodes), 1);
            isa_ok($nodes[0], 'Net::Kubernetes::Resource::Node');
        };
    };
};

runtests;
