package MooseX::App::Plugin::ConfigXDG;
$MooseX::App::Plugin::ConfigXDG::VERSION = '0.01';
# ABSTRACT: Config files in XDG config directories

use 5.010;
use utf8;

use namespace::autoclean;
use Moose::Role;
with qw(MooseX::App::Plugin::Config);

sub plugin_metaroles {
    my ($self, $class) = @_;

    return {
        class => [
            'MooseX::App::Plugin::Config::Meta::Class',
            'MooseX::App::Plugin::ConfigXDG::Meta::Class'
        ]
    };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

MooseX::App::Plugin::ConfigXDG - Config files in XDG config directories

=head1 VERSION

version 0.01

=head1 SYNOPSIS

In your base class:

 package MyApp;
 use MooseX::App qw(ConfigXDG);

=head1 DESCRIPTION

Works just like L<MooseX::App::Plugin::Config>, but assumes that the config
file always resides in the user's XDG config directory.  By default, this is
C<< $HOME/.config/${app-base}/config.(yml|xml|ini|...) >>.

You can override the XDG config base (from C<< $HOME/.config >>) with the
environmental variable C<XDG_CONFIG_HOME>.

=head1 SOURCE

The development version is on github at L<https://https://github.com/mschout/perl-moosex-app-plugin-configxdg>
and may be cloned from L<git://https://github.com/mschout/perl-moosex-app-plugin-configxdg.git>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
L<https://github.com/mschout/perl-moosex-app-plugin-configxdg/issues>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Michael Schout <mschout@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Michael Schout.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
