package TV::ProgrammesSchedules::Colors;

use Moose;
use Moose::Util::TypeConstraints;
use namespace::clean;

use Carp;
use Data::Dumper;

use Readonly;
use XML::Simple;
use HTTP::Request;
use LWP::UserAgent;
use HTML::Entities;
use Time::localtime;
use HTML::TreeBuilder;

=head1 NAME

TV::ProgrammesSchedules::Colors - Interface to Colors TV Programmes Schedules.

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';
Readonly my $BASE_URL =>
{
    'in'   => 'http://www.colorstv.in/schedule',
    'uk'   => 'http://www.colorstv.in/uk/schedule',
    'sg'   => 'http://www.colorstv.in/sg/schedule',
    'us'   => 'http://www.aapkacolors.com/schedule',
    'mena' => 'http://www.colorstv.in/mena/schedule',
    'rotw' => 'http://www.colorstv.in/rotw/schedule',
};

=head1 DESCRIPTION

Colors, known as Aapka Colors in the U.S.,  is  a  Hindi language Indian general entertainment
channel based in Mumbai,  part  of  the Viacom 18 family, which was launched on July 21, 2008.

On 21  January  2010,  Colors became available on Dish Network in the U.S., where it is called 
Aapka Colors (Respectfully your Colors) because of a clash with Colours TV.  Amitabh  Bachchan
served as brand ambassador for the UK and USA launches.

Colors launched in the United Kingdom and Ireland on Sky on 25 January 2010.On 5 January 2010,
Colors  secured  a  deal  to join the VIEWASIA subscription package. Initially the channel was
available free-to-air &  then subsequently was added to the VIEWASIA package on 19 April 2010.
Colors was added to Virgin Media on 1 April 2011, as a part of the Asian Mela pack.

=head1 CONSTRUCTOR

The constructor expects a reference to an anonymous hash as input parameter. Table below shows
the possible value of various keys (location, yyyy, mm, dd). The location, yyyy, mm and dd are 
all optional. Default location is 'in' .If missing picks up the current year, month and day.

    +----------------------------+----------+------+----+----+
    | Country                    | Location | YYYY | MM | DD |
    +----------------------------+----------+------+----+----+
    | India                      |    in    | 2011 |  4 |  7 |
    | United Kingdom             |    uk    | 2011 |  4 |  7 |
    | Singapore                  |    sg    | 2011 |  4 |  7 |
    | United States              |    us    | 2011 |  4 |  7 |
    | Middle East & North Africs |   mena   | 2011 |  4 |  7 |
    | Rest of the world          |   rotw   | 2011 |  4 |  7 |
    +----------------------------+----------+------+----+----+
    
    use strict; use warnings;
    use TV::ProgrammesSchedules::Colors;
    
    my ($colors);
    
    # Colors India (default) for todays (default) listings.
    $colors = TV::ProgrammesSchedules::Colors->new();

    # Colors UK for todays (default) listings.
    $colors = TV::ProgrammesSchedules::Colors->new('uk');

    # Colors US for 12th May'2011 listings.
    $colors = TV::ProgrammesSchedules::Colors->new({location => 'us', yyyy => 2011, mm => 5, dd => 12});

=cut

type 'Year'     => where { ($_ =~ m/^\d{4}$/) };
type 'Month'    => where { ($_ =~ m/^\d{1,2}$/) &&  ($_ >=1) && ($_<=12) };
type 'Day'      => where { ($_ =~ m/^\d{1,2}$/) &&  ($_ >=1) && ($_<=31) };
type 'Location' => where { ($_ =~ /\bin\b|\buk\b|\bsg\b|\bus\b|\bmena\b|\brotw\b/i) };
has 'location'  => (is => 'ro', isa => 'Location',          default => 'in');
has 'browser'   => (is => 'rw', isa => 'LWP::UserAgent',    default => sub { return LWP::UserAgent->new(); });
has 'tree'      => (is => 'rw', isa => 'HTML::TreeBuilder', default => sub { return HTML::TreeBuilder->new(); });
has 'yyyy'      => (is => 'ro', isa => 'Year',              default => sub { my $today = localtime; return $today->year+1900; });
has 'mm'        => (is => 'ro', isa => 'Month',             default => sub { my $today = localtime; return $today->mon+1;     });
has 'dd'        => (is => 'ro', isa => 'Day',               default => sub { my $today = localtime; return $today->mday;      });

around BUILDARGS => sub 
{
    my $orig  = shift;
    my $class = shift;

    if (@_ == 1 && ! ref $_[0]) 
    {
        return $class->$orig(location => $_[0]);
    }
    else 
    {
        return $class->$orig(@_);
    }
};

=head1 METHODS

=head2 get_listings()

Returns the programmes listings for the given location and date. Data would be in XML format.

    use strict; use warnings;
    use TV::ProgrammesSchedules::Colors;
    
    my ($colors, $listings);
    
    # Colors UK for todays listings.
    $colors   = TV::ProgrammesSchedules::Colors->new('uk');
    $listings = $colors->get_listings();

=cut

sub get_listings
{
    my $self = shift;
    
    my ($url, $request, $response, $content);
    $url      = $self->_getURL();
    $request  = HTTP::Request->new(GET => $url);
    $response = $self->{browser}->request($request);
    croak("ERROR: Could not fetch schedule [$url][".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    $content  = $self->_HTMLin($content);
    
    my ($time, $href, $title, $detail, $listings);
    # Doing it this way for fun and no other reasons whatsoever.
    foreach (@{$content->{html}->{body}->[0]->{table}->[0]->{tr}->[1]->{td}->[0]->{table}->[1]->{tr}->[1]->{td}->[1]->{table}->[0]->{tr}->[5]->{td}->[1]->{table}->[0]->{tr}->[1]->{td}->[0]->{table}->[0]->{tr}})
    {
        next unless defined $_->{td}->[3]->{span}->[0]->{a}->[0]->{content};
        
        # US Listings have 2 timings.
        (ref($_->{td}->[0]->{div}->[0]->{content}))
        ?
        ($time  = join(", ", @{$_->{td}->[0]->{div}->[0]->{content}}))
        :
        ($time  = $_->{td}->[0]->{div}->[0]->{content});
        $title  = $_->{td}->[3]->{span}->[0]->{a}->[0]->{content};
        $href   = $_->{td}->[3]->{span}->[1]->{a}->[0]->{href};
        $detail = $_->{td}->[3]->{span}->[1]->{a}->[0]->{content};
        push @{$listings}, { time => $time, title => $title, href => $href, detail => $detail };
    }
        
    warn("WARN: No schedule information found.\n") && return
        unless defined $listings;
        
    $self->{listings} = _toXML($listings);
    return $self->{listings};
}

sub _getURL
{
    my $self = shift;
    return sprintf("%s/%04d-%02d-%02d/", $BASE_URL->{lc($self->location)}, $self->yyyy, $self->mm, $self->dd);
}

sub _toXML
{
    my $data = shift;
    my $xml  = qq {<?xml version="1.0" encoding="UTF-8"?>\n};
    $xml.= qq {<programmes>\n};
    foreach (@{$data})
    {
        $xml .= qq {\t<programme>\n};
        $xml .= qq {\t\t<time> $_->{time} </time>\n};
        $xml .= qq {\t\t<title> $_->{title} </title>\n};
        $xml .= qq {\t\t<url> $_->{href} </url>\n} if exists($_->{href});
        $xml .= qq {\t\t<detail> $_->{detail} </detail>\n} if exists($_->{detail});
        $xml .= qq {\t</programme>\n};
    }
    $xml.= qq {</programmes>};
    return $xml;
}

sub _HTMLin
{
    my $self = shift;
    my $html = shift;
    
    my ($xml, $data);
    $self->{tree}->parse($html);
    $xml = $self->{tree}->as_XML();
    $self->{tree}->eof;
    $self->{tree}->delete;
    $data = XMLin($xml, ForceArray => 1);
    return { html => $data };
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs/feature requests to C<bug-tv-programmesschedules-colors at rt.cpan.org>
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TV-ProgrammesSchedules-Colors>.
I will be notified and then you'll automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc TV::ProgrammesSchedules::Colors

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=TV-ProgrammesSchedules-Colors>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/TV-ProgrammesSchedules-Colors>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/TV-ProgrammesSchedules-Colors>

=item * Search CPAN

L<http://search.cpan.org/dist/TV-ProgrammesSchedules-Colors/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__PACKAGE__->meta->make_immutable;
no Moose; # Keywords are removed from the TV::ProgrammesSchedules::Colors package

1; # End of TV::ProgrammesSchedules::Colors