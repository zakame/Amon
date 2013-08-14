# NAME

Amon2 - lightweight web application framework

# SYNOPSIS

    package MyApp;
    use parent qw/Amon2/;
    use Amon2::Config::Simple;
    sub load_config { Amon2::Config::Simple->load(shift) }

# DESCRIPTION

Amon2 is simple, readable, extensible, __STABLE__, __FAST__ web application framework based on [Plack](http://search.cpan.org/perldoc?Plack).

# METHODS

## CLASS METHODS for `Amon2` class

- my $c = MyApp->context();

    Get the context object.

- MyApp->set\_context($c)

    Set your context object(INTERNAL USE ONLY).

# CLASS METHODS for inherited class

- `MyApp->config()`

    This method returns configuration information. It is generated by `MyApp->load_config()`.

- `MyApp->mode_name()`

    This is a mode name for Amon2. The default implementation of this method is:

        sub mode_name { $ENV{PLACK_ENV} }

    You can override this method if you want to determine the mode by other method.

- `MyApp->new()`

    Create new context object.

- `MyApp->bootstrap()`

        my $c = MyApp->bootstrap();

    Create new context object and set it to global context. When you are writing CLI script, setup the global context object by this method.

- `MyApp->base_dir()`

    This method returns the application base directory.

- `MyApp->load_plugin($module_name[, \%config])`

    This method loads the plugin for the application.

    _$module\_name_ package name of the plugin. You can write it as two form like [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class):

        __PACKAGE__->load_plugin("Web::HTTPSession");    # => loads Amon2::Plugin::Web::HTTPSession

    If you want to load a plugin in your own name space, use the '+' character before a package name, like following:
        \_\_PACKAGE\_\_->load\_plugin("+MyApp::Plugin::Foo"); \# => loads MyApp::Plugin::Foo

- `MyApp->load_plugins($module_name[, \%config ], ...)`

    Load multiple plugins at one time.

    If you want to load a plugin in your own name space, use the '+' character before a package name like following:

        __PACKAGE__->load_plugins("+MyApp::Plugin::Foo"); # => loads MyApp::Plugin::Foo

- `MyApp->load_config()`

    You can get a configuration hashref from `config/$ENV{PLACK_ENV}.pl`. You can override this method for customizing configuration loading method.

- `MyApp->add_config()`

    DEPRECATED.

- `MyApp->debug_mode()`

    __((EXPERIMENTAL))__

    This method returns a boolean value. It returns true when $ENV{AMON2\_DEBUG} is true value, false otherwise.

    You can override this method if you need.

# PROJECT LOCAL MODE

__THIS MODE IS HIGHLY EXPERIMENTAL__

Normally, Amon2's context is stored in a global variable.

This module makes the context to project local.

It means, normally context class using Amon2 use `$Amon2::CONTEXT` in each project, but context class using ["PROJECT LOCAL MODE"](#PROJECT LOCAL MODE) use `$MyApp::CONTEXT`.

__It means you can't use code depend `<Amon2-`context__\> and `<Amon2-`context>> under this mode.>

## NOTES ABOUT create\_request

Older [Amon2::Web::Request](http://search.cpan.org/perldoc?Amon2::Web::Request) has only 1 argument like following, it uses `Amon2->context` to get encoding:

    sub create_request {
        my ($class, $env) = @_;
        Amon2::Web::Request->new($env);
    }

If you want to use ["PROJECT LOCAL MODE"](#PROJECT LOCAL MODE), you need to pass class name of context class, as following:

    sub create_request {
        my ($class, $env) = @_;
        Amon2::Web::Request->new($env, $class);
    }

## METHODS

This module inserts 3 methods to your context class.

- MyApp->context()

    Shorthand for $MyApp::CONTEXT

- MyApp->set\_context($context)

    It's the same as:

        $MyApp::CONTEXT = $context

- my $guard = MyApp->context\_guard()

    Create new context guard class.

    It's the same as:

        Amon2::ContextGuard->new(shift, \$MyApp::CONTEXT);

# DOCUMENTS

More complicated documents are available on [http://amon.64p.org/](http://amon.64p.org/)

# SUPPORTS

\#amon at irc.perl.org is also available.

# AUTHOR

Tokuhiro Matsuno <tokuhirom@gmail.com>

# LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.