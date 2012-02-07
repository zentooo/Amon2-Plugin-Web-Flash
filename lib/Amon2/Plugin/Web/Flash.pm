package Amon2::Plugin::Web::Flash;
use strict;
use warnings;

our $VERSION = '0.01';

use Amon2::Util;


sub init {
    my ($class, $c, $conf) = @_;
    my $webpkg = ref $c || $c;

    die 'Amon2::Plugin::Web::Flash depends on $c->session' unless $c->can("session");

    my $key = $conf->{session_key} || 'flash';
    my $new_key = $key . "_new";

    Amon2::Util::add_method($webpkg, flash => sub {
        my ($self, $value) = @_;
        $self->session->set($new_key, $value);
    });

    $c->add_trigger("BEFORE_DISPATCH" => sub {
        my $c = shift;

        $c->session->remove($key);

        my $val = $c->session->get($new_key);
        $c->session->remove($new_key);
        $c->session->set($key, $val) if $val;
    });
}

1;

__END__

=head1 NAME

Amon2::Plugin::Web::Flash - Perl extention to do something

=head1 VERSION

This document describes Amon2::Plugin::Web::Flash version 0.01.

=head1 SYNOPSIS

    use Amon2::Plugin::Web::Flash;

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

<<YOUR NAME HERE>> E<lt><<YOUR EMAIL ADDRESS HERE>>E<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, <<YOUR NAME HERE>>. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
