#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.008001;
use lib 'lib';
use LWP::UserAgent;
use autodie;
use Data::Dumper;
use File::Basename;
use File::Temp qw/tmpnam tempdir/;
use Text::Xslate;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

my $xslate = Text::Xslate->new(
    syntax    => 'TTerse',
    module    => ['Data::Dumper'],
    type      => 'text',
    tag_start => '<%',
    tag_end   => '%>',
);
my $ua = LWP::UserAgent->new();

__PACKAGE__->register_js(
    'run_es5shim',
    'https://raw.github.com/es-shims/es5-shim/v4.0.3/es5-shim.min.js',
    'ES5Shim',
);
__PACKAGE__->register_js(
    'run_strftimejs',
    'https://raw.github.com/tokuhirom/strftime-js/master/strftime.js',
    'StrftimeJS',
);
__PACKAGE__->register_js(
    'run_sprintf_js',
    'https://raw.github.com/alexei/sprintf.js/v0.7/src/sprintf.js',
    'SprintfJS',
);
__PACKAGE__->register_js(
    'run_micro_location_js',
    'https://raw.github.com/cho45/micro-location.js/master/lib/micro-location.js',
    'MicroLocationJS',
);
__PACKAGE__->register_js(
    'run_micro_dispatcher_js',
    'https://raw.github.com/tokuhirom/micro_dispatcher.js/master/micro_dispatcher.js',
    'MicroDispatcherJS',
);
__PACKAGE__->register_js(
    'run_xsrf_token_js',
    'https://raw.github.com/tokuhirom/HTTP-Session2/master/js/xsrf-token.js',
    'XSRFTokenJS',
);

&main;exit;

sub main {
    local $Data::Dumper::Terse = 1;

    if (@ARGV) {
        my $code = __PACKAGE__->can($ARGV[0])
            or die "Unknown method: $ARGV[0]";
        $code->();
    } else {
        run_jquery();
        run_bootstrap();

        run_es5shim();
        run_strftimejs();
        run_micro_template_js();
        run_sprintf_js();
        run_micro_location_js();
        run_micro_dispatcher_js();
        run_xsrf_token_js();
    }
}

sub slurp {
    open my $fh, '<', shift;
    local $/;
    <$fh>;
}

sub run_micro_template_js {
    my $content = <<'...';
// Simple JavaScript Templating
// John Resig - http://ejohn.org/ - MIT Licensed
(function(){
    var cache = {};
    this.tmpl = function tmpl(str, data){
        // Figure out if we're getting a template, or if we need to
        // load the template - and be sure to cache the result.
        var fn = !/\W/.test(str) ?
            cache[str] = cache[str] ||
            tmpl(document.getElementById(str).innerHTML) :

        // Generate a reusable function that will serve as a template
        // generator (and which will be cached).
        new Function("obj",
                     "var p=[];" +

                     // Introduce the data as local variables using with(){}
                     "with(obj){p.push('" +

                     // Convert the template into pure JavaScript
                     str
                     .replace(/[\r\t\n]/g, " ")
                     .split("<%").join("\t")
                     .replace(/(^|%>)[^\t]*?(\t|$)/g, function(){return arguments[0].split("'").join("\\'");})
                     .replace(/\t==(.*?)%>/g,"',$1,'")
                     .replace(/\t=(.*?)%>/g, "',(($1)+'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\"/g,'&quot;').replace(/\'/g,'&#39;'),'")
                     .split("\t").join("');")
                     .split("%>").join("p.push('")
                     + "');}return p.join('');");

        // Provide some basic currying to the user
        return data ? fn( data ) : fn;
    };
})();
...

    open my $fh, '>:utf8', 'lib/Amon2/Setup/Asset/MicroTemplateJS.pm';
    print {$fh} $xslate->render_string(<<'...', +{ file => $0, basename => 'micro_template.js', data => Dumper({ 'js/micro_template.js' => $content})});
# This file is generated by <% file %>. Do not edit manually.
package Amon2::Setup::Asset::MicroTemplateJS;
use strict;
use warnings;

sub tags {
    <<',,,';
    <script src="<: uri_for('/static/js/<% basename %>') :>"></script>
,,,
}

sub files {
    return <% data %>;
}

1;
...
    close $fh;
}


sub register_js {
    my ($class, $method, $url, $name) = @_;

    no strict 'refs';
    *{__PACKAGE__ . '::' . $method} = sub {
        use strict;

        my $res = $ua->get($url);
        $res->is_success or die "Cannot fetch $url: " . $res->status_line;

        my $content = $res->decoded_content;
        open my $fh, '>:utf8', "lib/Amon2/Setup/Asset/${name}.pm";
        print {$fh} $xslate->render_string(<<'...', +{ file => $0, basename => basename($url), name => $name, data => Dumper({ 'js/' . basename($url) => $content})});
# This file is generated by <% file %>. Do not edit manually.
package Amon2::Setup::Asset::<% name %>;
use strict;
use warnings;

sub tags {
    <<',,,';
    <script src="<: uri_for('/static/js/<% basename %>') :>"></script>
,,,
}

sub files {
    return <% data %>;
}

1;
...
        close $fh;
    };
}

sub run_jquery {
    my $url = 'http://code.jquery.com/jquery-3.2.1.min.js';
    my $res = $ua->get($url);
    $res->is_success or die "Cannot fetch $url: " . $res->status_line;

    my $jquery = $res->decoded_content;
    open my $fh, '>:utf8', 'lib/Amon2/Setup/Asset/jQuery.pm';
    print {$fh} $xslate->render_string(<<'...', +{ file => $0, basename => basename($url), data => Dumper({ 'js/' . basename($url) => $jquery})});
# This file is generated by <% file %>. Do not edit manually.
package Amon2::Setup::Asset::jQuery;
use strict;
use warnings;

sub tags {
    <<',,,';
    <script src="<: uri_for('/static/js/<% basename %>') :>"></script>
,,,
}

sub files {
    return <% data %>;
}

# for backward compatibility
sub run {
    warn "THIS METHOD WAS DEPRECATED";
    my ($self, $flavor) = @_;
    $flavor->mkpath('static/js/');
    $flavor->write_file_raw("static/js/<% basename %>", $self->files->{'<% basename %>'});
}

1;
...
    close $fh;
}

sub fetch {
    my $url = shift;
    my $res = $ua->get($url);
    $res->is_success or die "Cannot fetch $url: " . $res->status_line;
    return $res->decoded_content;
}

sub run_bootstrap {
    my $files = {};
    print "Fetching bootstrap\n";
    my $zip_url = 'https://github.com/twbs/bootstrap/archive/v3.3.5.zip';
    my $tmpdir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp = "$tmpdir/bootstrap.zip";
    print "Saving files to $tmp\n";
    my $res = $ua->mirror($zip_url, $tmp);
    $res->is_success or die $res->status_line;
    -s $tmp > 0 or die 'File is too short';
    my $zip = Archive::Zip->new();
    $zip->read($tmp)==AZ_OK or die "Cannot read zip file";
    for my $member ($zip->members()) {
        next if $member->isDirectory;
        my $contents = $member->contents();
        my $filename = $member->fileName;
        my $basename = File::Basename::basename($filename);
        next if $basename eq '.gitignore';
        next if $basename eq '.travis.yml';
        next if $filename =~ m{/examples/};
        next if $filename =~ m{/less/};
        next if $filename =~ m{/tests/};
        if ($filename =~ m{/dist/(.*)\z}) {
            $files->{"bootstrap/$1"} = $contents;
        }
    }

    local $Data::Dumper::Useqq = 1;
    local $Data::Dumper::Sortkeys = 1;
   my $content = $xslate->render_string(<<'...', {script => $0, content => Dumper($files)});
# This file is generated by <% script %>. Do not edit manually.
package Amon2::Setup::Asset::Bootstrap;
use strict;
use warnings;

sub tags {
    <<',,,';
    <link href="<: uri_for('/static/bootstrap/css/bootstrap.css') :>" rel="stylesheet" type="text/css" />
    <script src="<: uri_for('/static/bootstrap/js/bootstrap.js') :>"></script>
,,,
}

sub files { <% content %> }

sub run {
    my ($class, $flavor) = @_;
    warn "THIS METHOD WAS DEPRECATED";

    my $files = $class->files;
    $flavor->mkpath('static/bootstrap/');
    while (my ($fname, $content) = each %$files) {
        $flavor->write_file_raw("static/$fname", uri_unescape($content));
    }
}

1;
...

    open my $fh, '>:utf8', 'lib/Amon2/Setup/Asset/Bootstrap.pm';
    print {$fh} $content;
    close $fh;

    eval "use Amon2::Setup::Asset::Bootstrap;";
    die $@ if $@;
}

