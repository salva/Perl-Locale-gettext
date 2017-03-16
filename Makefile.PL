use ExtUtils::MakeMaker;
use Config;

use Devel::CheckLib qw(check_lib);


my %cl_opts = (header => 'libintl.h', debug => 1);
unless (check_lib(function => 'char *x = gettext("foo"); return 0;', %cl_opts)) {
    $cl_opts{lib} = 'intl';
    unless (check_lib(function => 'char *x = gettext("foo"); return 0;', %cl_opts)) {
        die "gettext not supported!\n";
    }
}

open(CONFIG, ">config.h");
print CONFIG "/* Generated automatically by ", $0, ". Do not edit */\n";

sub test_func {
    my $fn = shift;
    my $code = shift;
    my $expected = shift || 0;
    check_lib(%cl_opts,
              function => "$code; exit(0);",
              analize_binary => sub {
                  if (system $_[1] == $expected) {
                      print CONFIG "HAVE_" .uc($fn)." 1\n";
                  }
              });

    print CONFIG "#define HAVE_" .uc($fn)." 1\n";
}

test_func(dgettext => 'char *x = dcgettext("foo", "bar", 0)', 1);
test_func(ngettext => 'char *x = ngettext("foo", "foos", 1)', 1);
test_func(bind_textdomain_codeset => 'char *x = bind_textdomain_codeset("foo", "UTF-8")', 1);
close CONFIG;

WriteMakefile(
    NAME => "Locale::gettext",
    VERSION_FROM => 'gettext.pm',
    LICENSE => 'perl_5',
    (defined $cl_opts{lib} ? (LIBS => "-l$cl_opts{lib}") : ()),
    META_MERGE => {
        resources => {
            repository => 'https://github.com/vandry/Perl-Locale-gettext',
            license => 'http://dev.perl.org/licenses/',
        },
    },
    ABSTRACT => "Perl bindings for POSIX i18n gettext functions",
    AUTHOR => "Kim Vandry <vandry@TZoNE.ORG>",
    LICENSE => 'perl',
);
