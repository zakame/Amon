use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp qw(tempdir);
use FindBin;
use lib "$FindBin::Bin/../../lib/";

use Amon2::Setup::Asset::jQuery;
use Amon2::Setup;

my $orig_cwd = Cwd::getcwd();

my $tmpdir = tempdir(CLEANUP => 1);

chdir $tmpdir;

my $flavor = Amon2::Setup->new(module => 'Foo');
$flavor->load_asset('jQuery');
$flavor->load_asset('Bootstrap');
ok(-f 'static/bootstrap/bootstrap.min.css');
ok(-d 'static/js/');
ok(-f 'static/bootstrap/bootstrap-dropdown.js');

like($flavor->{tags}, qr/jquery-.+\.js/);
like($flavor->{tags}, qr/bootstrap.min.css/);

chdir $orig_cwd;
undef $tmpdir;

done_testing;

