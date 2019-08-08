package MooseX::App::Plugin::ConfigXDG::Meta::Class;
$MooseX::App::Plugin::ConfigXDG::Meta::Class::VERSION = '0.01';
use 5.010;
use utf8;

use namespace::autoclean;
use Moose::Role;

use File::HomeDir ();
use File::Spec ();

around proto_config => sub {
    my $orig = shift;
    my ($self,$command_class,$result,$errors) = @_;

    unless (defined $result->{config}) {
        my $xdg_config_home = $ENV{XDG_CONFIG_HOME}
            || File::Spec->catdir( File::HomeDir->my_home, '.config' );

        my $config_dir = File::Spec->catdir($xdg_config_home, $self->app_base);

        foreach my $extension (Config::Any->extensions) {
            my $check_file = File::Spec->catfile($config_dir, 'config.'.$extension);
            if (-e $check_file) {
                $result->{config} = $check_file;
                last;
            }
        }
    }

    return $self->$orig($command_class,$result,$errors);
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

MooseX::App::Plugin::ConfigXDG::Meta::Class

=head1 VERSION

version 0.01

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
