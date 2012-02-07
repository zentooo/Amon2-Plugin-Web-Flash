use strict;
use warnings;
use Test::More;

use Plack::Request;
use Plack::Test;
use Test::Requires 'Amon2::Lite';

use HTTP::Session::State::URI;


my ($session_id, $session_key) = (undef, 'sid');
my $state = HTTP::Session::State::URI->new(
    session_id_name => $session_key,
);

my $app = do {
    package MyApp::Web;
    use Amon2::Lite;

    sub load_config { +{} }

    __PACKAGE__->load_plugins(
        'Web::HTTPSession' => {
            state => $state,
            store => 'OnMemory',
        },
        'Web::Flash',
    );

    get '/set' => sub {
        my $c = shift;
        $session_id = $c->session->{session_id};

        $c->flash("Honey");

        $c->render('index.tt', +{
            flash_new => $c->session->get("flash_new"),
            flash => $c->flash,
        });
    };

    get '/use' => sub {
        my $c = shift;
        $session_id = $c->session->{session_id};

        $c->render('index.tt', +{
            flash_new => $c->session->get("flash_new"),
            flash => $c->flash,
        });
    };

    get '/after' => sub {
        my $c = shift;
        $session_id = $c->session->{session_id};

        $c->render('index.tt', +{
            flash_new => $c->session->get("flash_new"),
            flash => $c->flash,
        });
    };

    __PACKAGE__->to_app;
};


subtest 'set and get and turn' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            {
                my $res = $cb->(HTTP::Request->new(GET => "http://localhost/set"));
                note $res->content;
                like $res->content, qr/Honey flash new/;
                unlike $res->content, qr/Honey flash!/;
            }

            {
                my $res = $cb->(HTTP::Request->new(GET => "http://localhost/use?sid=$session_id"));
                note $res->content;
                unlike $res->content, qr/Honey flash new/;
                like $res->content, qr/Honey flash!/;
            }

            {
                my $res = $cb->(HTTP::Request->new(GET => "http://localhost/after?sid=$session_id"));
                note $res->content;
                unlike $res->content, qr/Honey flash new/;
                unlike $res->content, qr/Honey flash!/;
            }
        };
};


done_testing;

package MyApp::Web;
__DATA__

@@ index.tt
[% flash_new %] flash new
<br/>
[% flash %] flash!
