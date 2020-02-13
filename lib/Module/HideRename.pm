package Module::HideRename;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;
use Log::ger;

our %SPEC;

use Exporter qw(import);
our @EXPORT_OK = qw(hiderename_modules unhiderename_modules);

use Module::Path::More;
# XXX check whether Module::Path::More::Patch::Hide has been loaded?

my $unhide;
sub _hiderename_modules {
    my %args = @_;

    for my $module (@{ $args{modules} }) {
        my $paths = Module::Path::More::module_path(
            module => $unhide ? "${module}_hidden" : $module,
            all => 1,
        );
        for my $path (@$paths) {
            my $new_path = $path;
            if ($unhide) {
                $new_path =~ s/_hidden(\.pmc?\z)/$1/;
            } else {
                $new_path =~ s/(\.pmc?\z)/_hidden$1/;
            }
            log_debug "%s module: %s -> %s",
                ($unhide ? "Unhide-renaming" : "Hide-renaming"),
                $path, $new_path;
            rename $path, $new_path
                or warn "Can't rename $path -> $new_path: $!";
        }
    }
}

$SPEC{hiderename_modules} = {
    v => 1.1,
    args => {
        modules => ['array*', of=>'perl::modname*'],
        req => 1,
        pos => 0,
        slurpy => 1,
    },
};
sub hiderename_modules {
    $unhide = 0;
    goto &_hiderename_modules;
}

$SPEC{unhiderename_modules} = {
    v => 1.1,
    args => {
        modules => ['array*', of=>'perl::modname*'],
        req => 1,
        pos => 0,
        slurpy => 1,
    },
};
sub unhiderename_modules {
    $unhide = 1;
    goto &_hiderename_modules;
}

1;
# ABSTRACT: Hide modules by renaming them

=head1 SYNOPSIS

 use Module::HideRename qw(
     hiderename_modules
     unhiderename_modules
 );

 hiderename_modules(modules => ['Foo', 'Foo::Bar']);
 # this will rename Foo.pm to Foo_hidden.pm and Foo/Bar.pm to Foo/Bar_hidden.pm

 unhiderename_modules(modules => ['Foo', 'Foo::Bar']);
 # this will rename back Foo_hidden.pm to Foo.pm and Foo/Bar_hidden.pm to Foo/Bar.pm


=head1 DESCRIPTION

Sometimes all you need to do to hide a module from a Perl code is install an
C<@INC> hook (e.g. like what L<Devel::Hide> or L<Test::Without::Module> does).
But sometimes you actually need to hide (rename) the module files.


=head1 SEE ALSO

L<App::pmhiderename>, CLI for hiderenaming

L<lib::hiderename>, pragma for hiderenaming

=cut
