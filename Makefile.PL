use ExtUtils::MakeMaker;
use Config;

my @LIBS;
my %define;
use Config::AutoConf;
my $ac = Config::AutoConf->new;
$ac->check_valid_compiler() or die;
unless ($ac->check_header('libintl.h')) {
    if ($^O eq 'MSWin32' and eval { require Alien::WinBuilds; 1}) {
        warn "Using Alien::WinBuilds to install required libraries...\n";
        my $awb = Alien::WinBuilds->new;
        $awb->web('win-iconv', 'gettext');
        $ac = Config::AutoConf->new;
        $ac->check_valid_compiler() or die;
        $ac->push_library_paths($awb->lib);
        push @LIBS, '-L' . $awb->lib;
        $ac->push_includes($awb->include);
        $ac->check_header('libintl.h') or die;
    }
    else {
        die;
    }
}

for my $symbol (qw(gettext dgettext dcgettext ngettext bind_textdomain_codeset)) {
    if (my $lib = $ac->search_libs($symbol, ['intl'])) {
        $libs{$lib} = 1 unless $lib eq 'none required';
    }
    else {
        die if $symbol eq 'gettext';
    }
}

push @LIBS, map "-l$_" for sort keys %libs;

$ac->write_config_h;

WriteMakefile(
    NAME => "Locale::gettext",
    VERSION_FROM => 'gettext.pm',
    LICENSE => 'perl_5',
    (@LIBS ? (LIBS => join ' ', @LIBS) : ()),
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
