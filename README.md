# NAME

Plack::App::GrowthForecast::SafeProxy - GrowthForecast contents safe proxy application

# SYNOPSIS

    use Plack::App::GrowthForecast::SafeProxy;

    my $app = Plack::App::GrowthForecast::SafeProxy->new(
        base_url     => 'http://gf.example.com',
        service_name => 'game',
        section_name => 'ninjya',
    )->to_app;

    builder {
        mount => '/gf/' => $app,
    };

# DESCRIPTION

Plack::App::GrowthForecast::SafeProxy is

# AUTHOR

Kazuhiro Osawa <yappo {at} shibuya {dot} pl>

# COPYRIGHT

Copyright 2014- Kazuhiro Osawa

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
