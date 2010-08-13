use strict;
use warnings;

package MyApp;
use base 'WebNano';
use Object::Tiny 'config';
use Config::Any;
use WebNano::TTTRenderer;

sub new {
    my $class = shift;
    my $self  = bless {}, $class ;
    my $cfg = Config::Any->load_stems({ stems => [ $self->config_file ], use_ext => 1 }); 
    my @values = values %{$cfg->[0]};
    my $config = $values[0];
    $self->{config} = $config;
    $self->{renderer} = WebNano::TTTRenderer->new( %{ $config->{renderer} } );
    return $self;
}

sub config_file { 't/data/app' }

1;

