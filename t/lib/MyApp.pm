package MyApp;
use Moose;
use MooseX::NonMoose;
extends 'WebNano';
use Config::Any;
use WebNano::TTTRenderer;

has config => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );

sub _build_config {
    my( $self ) = @_;
    return $self->get_config( 't/data/app' );
}

has renderer => ( is => 'ro', lazy_build => 1 );
sub _build_renderer {
    my $self = shift;
    my $config = $self->config->{renderer};
    return WebNano::TTTRenderer->new( %$config );
}

sub get_config {
    my( $self, $conf_file ) = @_; 
    
    my $cfg = Config::Any->load_stems({ stems => [ $conf_file ], use_ext => 1 }); 
    my @values = values %{$cfg->[0]};
    return $values[0];
}

1;

