# ABSTRACT: Post-Modern CGI scripting

package tinycgi;
{
    $tinycgi::VERSION = '0.0.0_01';
}

use base 'CGI::Application';

our $routes;
our $script;

our $VERSION = '0.0.0_01';    # VERSION


sub import {

    strict->import;
    warnings->import;

    $routes = $_[1];
    $script = caller(0);

}

sub setup {

    my ($self, @spec) = @_;

    # hackaroni toni

    my $this = ref $self;

    unshift @{$self->{__CALLBACK_CLASSES}}, $script;

    my @routines = grep { defined &{"$script\::$_"} }
      keys %{"$script\::"};

    foreach my $routine (@routines) {

        eval { *{"$this\::$routine"} = \&{"$script\::$routine"} };

    }

    # sane shane

    my %spec;

    $routes = {} unless ref $routes;

    if (defined $routes) {

        if ("HASH" eq ref $routes) {
            @spec = %{$routes};
            unshift @spec, 'index', 'index', grep { $_ ne 'index' } @spec;
        }

        elsif ("ARRAY" eq ref $routes) {
            @spec = @{$routes};
            unshift @spec, 'index', grep { $_ ne 'index' } @spec;
            @spec = map { $_ => $_ } @spec;
        }

        %spec = @spec;

    }

    $self->start_mode('index');

    $self->mode_param('route');

    $self->run_modes(%spec);

}

END {

    if (defined $routes && defined $script) {

        __PACKAGE__->new->run

    }

}

1;

__END__

=pod

=head1 NAME

tinycgi - Post-Modern CGI scripting

=head1 VERSION

version 0.0.0_01

=head1 SYNOPSIS

    #!/usr/bin/env perl
    
    use tinycgi -run; # autorun
    
    sub index {
        # i'm supposed to be doing something here
        return '... Oh, ... Hello World!'
    }

run automatically with run-modes ...

    #!/usr/bin/env perl
    
    use tinycgi {
        hi => 'say_hi'
    };
    
    sub index {
        # i'm supposed to be doing something here
        return '... Oh, ... Hello World!'
    }
    
    sub say_hi {
        return ('Hello', 'Ni hao', 'Konnichiwa', 'Buon giorno')[rand(4)])
    }

run when called ...

    #!/usr/bin/env perl
    
    use tinycgi;
    
    sub index {
        # i'm supposed to be doing something here
        return '... Oh, ... Hello World!'
    }
    
    my $app = tinycgi->new->run;

=head1 DESCRIPTION

More to come soon as I have big plans for this space. Basically I still write
one-off cgi-scripts from time-to-time and deploy them in various environments.
Sometimes dependencies are a problem, sometimes they're not, ... the point is
I don't mind working in these evironments and writing cgi-scripts but I would
like do so easily and more efficiently.

So currently (hopefully not for long), tinycgi wraps CGI::Application and does
a bunch of setup stuff for you. I have a bigger picture in mind but I don't care
to dump it in POD atm, although it may look something like ....

    (fatpack file; cat tinycgi.pm) >tinycgi.pm
    wget http://tinycgi.pm
    chmod 0644 tinycgi.pm
    curl http://localhost/cgi-bin/test.pl

=head1 AUTHOR

Al Newkirk <awncorp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by awncorp.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

