package WebNano::Renderer::TTiny;
use strict;
use warnings;

use Template::Tiny;
use Object::Tiny::RW qw/ root _tt_tiny INCLUDE_PATH TEMPLATE_EXTENSION /;
use File::Spec;


sub _to_list {
    if( ref $_[0] ){
        return @{ $_[0] };
    }
    elsif( ! defined $_[0] ){
        return ();
    }
    else{
        return $_[0];
    }
}

sub render {
    my( $self, %vars ) = @_;
    my $c = $vars{c};

    my @search_path;
    if( $c ){
        my $path = ref $c;
        $path =~ s/.*::Controller(::)?//;
        $path =~ s{::}{/};
        @search_path = ( $path, @{ $c->template_search_path });
    }
    if( !@search_path ){
        @search_path = ( '' );
    }
    my $template = $vars{template};
    if( !$template ){
        my @caller = caller(2);
        $template =  $caller[3];
        $template =~ s/_action$//;
        $template =~ s/^.*:://;
        $template .= '.' . $self->TEMPLATE_EXTENSION if $self->TEMPLATE_EXTENSION;
    }
    my $full_template;
    LOOP:
    for my $path ( @search_path ){
        my $to_check;
        if( !$self->root || File::Spec->file_name_is_absolute( $path ) ){
            $to_check = File::Spec->catfile( $path, $template );
            if( -f $to_check ){ 
                $full_template = $to_check;
                last LOOP;
            }
        }
        else{
            for my $root ( _to_list( $self->root ) ){
                $to_check = File::Spec->catfile( $root, $path, $template );
                if( -f $to_check ){ 
                    $full_template = $to_check;
                    last LOOP;
                }
            }
        }
    }
    my @static_search_path;
    if( !$full_template ){
        @static_search_path = _to_list( $self->INCLUDE_PATH );
        STATIC_LOOP:
        for my $path ( @static_search_path ){
            my $to_check;
            $to_check = File::Spec->catfile( $path, $template );
            if( -f $to_check ){ 
                $full_template = $to_check;
                last STATIC_LOOP;
            }
        }
    }
    die "Cannot find $template in search path: @search_path, @static_search_path" if !defined $full_template;
    open my $fh, $full_template or die "Cannot read from $full_template: $!";
    my $string = do { local $/; <$fh> };
    if( !$self->_tt_tiny ){
        $self->_tt_tiny( Template::Tiny->new() );
    }
    my $out;
    $self->_tt_tiny->process( \$string, \%vars, \$out );
    return $out;
}

1;
