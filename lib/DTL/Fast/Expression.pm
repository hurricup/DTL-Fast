package DTL::Fast::Expression;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Replacer';
use Carp qw(confess);

use DTL::Fast::Variable;
use DTL::Fast::Expression::Operator;
use DTL::Fast::Replacer::Replacement;

use Data::Dumper;

our %EXPRESSION_CACHE = ();
our $EXPRESSION_CACHE_HITS = 0;

# @todo cache mechanism via get_expression
sub new
{
    my $proto = shift;
    my $expression = shift;
    my %kwargs = @_;
    my $result = undef;

    $expression =~ s/(^\s+|\s+$)//gsi;
    
    if( 
        not $kwargs{'replacement'}          # cache only top-level expressions
        and not $kwargs{'level'}            # same ^^
        and $EXPRESSION_CACHE{$expression}  # has cached expression
    )
    {
        $result = $EXPRESSION_CACHE{$expression};
        $EXPRESSION_CACHE_HITS++;
    }
    else
    {
        $kwargs{'expression'} = $expression;
        $kwargs{'level'} //= 0;        
            
        my $self = $proto->SUPER::new(%kwargs);

        $self->{'expression'} = $self->_parse_expression(
            $self->_parse_brackets(
                $self->backup_strings($expression)
            )
        );

        $EXPRESSION_CACHE{$expression} = $result = $self->{'expression'};
    }
   
    return $result;
}

sub _parse_brackets
{
    my $self = shift;
    my $expression = shift;

    $expression =~ s/\s+/ /gsi;
    while( $expression =~ s/\(\s*([^()]+)\s*\)/$self->backup_expression($1)/ge ){};
    
    confess 'Unpaired brackets in: '.$self->{'expression'}
        if $expression =~ /[()]/;
    
    return $expression;
}


sub _parse_expression
{
    my $self = shift;
    my $expression = shift;
    
    my $result = undef;
    
    for( my $level = $self->{'level'}; $level < scalar @{$DTL::Fast::Expression::Operator::OPERATORS}; $level++ )
    {
        my $precedence = $DTL::Fast::Expression::Operator::OPERATORS->[$level];
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
                    push @result, $self->get_backup_or_expression($token, $level);
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
                        confess 'Two operands in a row: '.$self->{'expression'};
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
                        
                        if( $handler eq 'DTL::Fast::Expression::Operator::Unary' )
                        {
                            if( defined $result )
                            {
                                confess sprintf('Unary operator %s got left argument: %s'
                                    , $token
                                    , $self->{'expression'}
                                );
                            }
                            else
                            {
                                $result = DTL::Fast::Expression::Operator->new( $token, $operand, '_template' => $self->{'_template'});
                            }
                        }
                        elsif($handler eq 'DTL::Fast::Expression::Operator::Binary')
                        {
                            if( defined $result )
                            {
                                $result = DTL::Fast::Expression::Operator->new( $token, $result, $operand, '_template' => $self->{'_template'});
                            }
                            else
                            {
                                confess sprintf('Binary operator %s has no left argument: %s'
                                    , $token
                                    , $self->{'expression'}
                                );
                            }
                        }
                        else
                        {
                            confess 'Unknown operator handler: '.$handler;
                        }
                    }
                    else # got operator but there is no more operands
                    {
                        confess sprintf('No right argument for %s (%s, %s, %s, %s): %s'
                            , $token // 'undef'
                            , scalar @result
                            , ref $result[0] // 'undef'
                            , $result // 'undef'
                            , $result[0] // 'undef'
                            , $self->{'expression'}
                        );
                    }
                }
            }
            last if $result;    # parsed level
        }
            
    }
    return 
        $result 
        // $self->get_backup_or_variable($expression)
        ;
}

1;