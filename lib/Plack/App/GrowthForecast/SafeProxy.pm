package Plack::App::GrowthForecast::SafeProxy;
use strict;
use warnings;
use parent qw(Plack::Component);
use Plack::Util::Accessor qw(base_url service_name section_name _ua);

use 5.008_005;
our $VERSION = '0.01';

use LWP::UserAgent;

sub prepare_app {
    my $self = shift;

    my $ua = LWP::UserAgent->new( agent => "Plack::App::GrowthForecast::SafeProxy/$Plack::App::GrowthForecast::SafeProxy::VERSION" );
    $self->_ua($ua);
}

sub res_404 { [ 404, [], ['404 Not Found'] ] }

sub call {
    my($self, $env) = @_;

    my $base_url     = $self->base_url;
    my $service_name = $self->service_name;
    my $section_name = $self->section_name;

    my $path  = $env->{PATH_INFO};
    my $query = $env->{QUERY_STRING};

    if ($path eq '/') {
        # index
        my $url = join '?', "$base_url/list/$service_name/$section_name", $query;
        my $res = $self->_ua->get($url);
        return $self->res_404 unless $res->is_success;

        my $content = $res->content;

        # remove header
        $content =~ s{<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">.+?</div>\s+</div>\s+</div>\s+}{}s;
        $content =~ s{<div class="page-header">.+?</div>\s+</div>\s+</div>\s+}{}s;
        # remove remove link
        $content =~ s{<p style="text-align: right;margin:20px 0px">.+?remove all graphs in this section.+?</p>}{}s;
        # remove footer
        $content =~ s{<div id="footer">.+?</div>\s+</div>\s+}{}s;

        # remove setting link
        $content =~ s{<a.+>.+?Setting</a>}{}g;

        # change static link
        $content =~ s{$base_url/(js/|css/|favicon.ico)}{./_static/$1}g;

        # change graph image
        $content =~ s{$base_url/graph/$service_name/$section_name/}{./_graph/}g;

        # self url
        $content =~ s{$base_url/list/$service_name/$section_name}{./}g;

        # remove other links
        $content =~ s{<a href="$base_url.+?>(.+?)</a>}{$1}g;
        $content =~ s{<a href="#.+?>(.+?)</a>}{$1}g;

        return [200, ['Content-Type', $res->header('content-type')], [$content] ];
    } elsif ($path =~ m{\A/_graph/(.+)\z}) {
        # graph image
        my $new_path = join '?', $1, $query;

        my $res = $self->_ua->get("$base_url/graph/$service_name/$section_name/$new_path");
        return $self->res_404 unless $res->is_success;
        return [200, [ 'Content-Type', $res->header('content-type') ], [$res->content] ];
    } elsif ($path =~ m{\A/_static/(.+)\z}) {
        # static files
        my $new_path = join '?', $1, $query;

        my $res = $self->_ua->get("$base_url/$new_path");
        return $self->res_404 unless $res->is_success;
        return [200, [ 'Content-Type', $res->header('content-type') ], [$res->content] ];
    }

    return $self->res_404;
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::App::GrowthForecast::SafeProxy - GrowthForecast contents safe proxy application

=head1 SYNOPSIS

  use Plack::App::GrowthForecast::SafeProxy;

  my $app = Plack::App::GrowthForecast::SafeProxy->new(
      base_url     => 'http://gf.example.com',
      service_name => 'game',
      section_name => 'ninjya',
  )->to_app;

  builder {
      mount => '/gf/' => $app,
  };

=head1 DESCRIPTION

Plack::App::GrowthForecast::SafeProxy is safe proxy for GrowthForecast contents.

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {at} shibuya {dot} plE<gt>

=head1 COPYRIGHT

Copyright 2014- Kazuhiro Osawa

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
