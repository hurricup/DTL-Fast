package DTL::Fast::Template::Expression;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template::Variable;
use DTL::Fast::Template::Expression::Operator;
use DTL::Fast::Template::Expression::Replacement;

use Data::Dumper;

# @todo cache mechanism via get_expression
# @todo expression validation on pre-compilation or execution time
sub new
{
    my $proto = shift;
    my $expression = shift;
    my %kwargs = @_;
    
    $kwargs{'replacement'} ||= DTL::Fast::Template::Expression::Replacement->new($expression);
    $kwargs{'level'} //= 0;        
        
#    warn "*Processing $expression";
        
    my $self = bless {
        'expression' => $expression
        , 'replacement' => $kwargs{'replacement'}
        , 'level' => $kwargs{'level'}
    }, $proto;
    
    $self->{'expression'} = $self->_parse_expression(
        $self->_parse_brackets(
            $self->_parse_strings($expression)
        )
    );

#    warn "*Processed as $self->{'expression'}";
    
    return $self->{'expression'};
}

sub _parse_strings
{
    my $self = shift;
    my $expression = shift;

    while( $expression =~ s/(?<!\\)(".+?(?<!\\)")/$self->_get_string_replacement($1)/ge ){};
    
    return $expression;
}

sub _parse_brackets
{
    my $self = shift;
    my $expression = shift;

    $expression =~ s/\s+/ /gsi;
    while( $expression =~ s/\(([^()]+)\)/$self->_get_brackets_replacement($1)/ge ){};
    
    die 'Unpaired brackets in: '.$self->{'expression'}
        if $expression =~ /[()]/;
    
    return $expression;
}

sub _get_string_replacement
{
    my $self = shift;
    my $string = shift;
    
    return $self->{'replacement'}->add_replacement(new DTL::Fast::Template::Variable($string));
}

sub _get_brackets_replacement
{
    my $self = shift;
    my $expression = shift;

    return $self->{'replacement'}->add_replacement(
        DTL::Fast::Template::Expression->new(
            $expression
            , 'replacement' => $self->{'replacement'}
            , 'level' => 0 
        )
    );
}

sub _get_block_or_expression
{
    my $self = shift;
    my $token = shift;
    my $level = shift;

#    warn "Reading replacement for $token";
    
    my $result = $self->{'replacement'}->get_replacement($token)
        // DTL::Fast::Template::Expression->new(
            $token
            , 'replacement' => $self->{'replacement'}
            , 'level' => $level+1 
        );
        
#    warn "Got $result";
        
    return $result;
}

sub _parse_expression
{
    my $self = shift;
    my $expression = shift;
    
    my $result = undef;
    
    for( my $level = $self->{'level'}; $level < scalar @{$DTL::Fast::Template::Expression::Operator::OPERATORS}; $level++ )
    {
        my $precedence = $DTL::Fast::Template::Expression::Operator::OPERATORS->[$level];
        my( $operators, $handler ) = @$precedence;

        my @result = ();
        my @source = split /(?:^|\s+)($operators)(?:$|\s+)/, $expression;

        if( scalar @source > 1 ) 
        {
 #           warn "Parsed $expression as ".Dumper(\@source);
            
            # processing operands
            while( defined ( my $token = shift @source) )
            {
                next if $token eq ''; 
                
                if( $token =~ /$operators/ ) # operation
                {
                    push @result, $token;
                }
                else 
                {
                    push @result, $self->_get_block_or_expression($token, $level);
                }
            }
            
            # processing operators
            while( my $token  = shift @result )
            {
#                warn "Processing token $token";
                if( ref $token ) # operand
                {
                    if( defined $result )
                    {
                        die 'Two operands in a row: '.$self->{'expression'};
                    }
                    else
                    {
                        $result = $token;
                    }
                }
                else    # operator
                {
                    if( 
                        scalar @result      # there is a next token
                        and ref $result[0]  # it's an operand
                    )
                    {
                        my $operand = shift @result;
                        
                        if( $handler eq 'DTL::Fast::Template::Expression::Operator::Unary' )
                        {
                            if( defined $result )
                            {
                                die sprintf('Unary operator %s got left argument: %s'
                                    , $token
                                    , $self->{'expression'}
                                );
                            }
                            else
                            {
                                $result = DTL::Fast::Template::Expression::Operator::Unary->new( $token, $operand);
                            }
                        }
                        elsif($handler eq 'DTL::Fast::Template::Expression::Operator::Binary')
                        {
                            if( defined $result )
                            {
                                $result = DTL::Fast::Template::Expression::Operator::Binary->new( $token, $result, $operand);
                            }
                            else
                            {
                                die sprintf('Binary operator %s has no left argument: %s'
                                    , $token
                                    , $self->{'expression'}
                                );
                            }
                        }
                        else
                        {
                            die 'Unknown operator handler: '.$handler;
                        }
                    }
                    else # got operator but there is no more operands
                    {
                        die sprintf('No right argument for %s (%s, %s, %s, %s): %s'
                            , $token
                            , scalar @result
                            , ref $result[0] // 'undef'
                            , $result
                            , $result[0] // 'undef'
                            , $self->{'expression'}
                        );
                    }
                }
            }
            last if $result;    # parsed level
        }
            
    }
    return $result // DTL::Fast::Template::Variable->new($expression);
}

1;