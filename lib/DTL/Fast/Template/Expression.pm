package DTL::Fast::Template::Expression;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template::Variable;
use DTL::Fast::Template::Expression::Operator;

# @todo cache mechanism via get_expression
# @todo expression validation on pre-compilation or execution time
sub new
{
    my $proto = shift;
    my $expression = shift;
    
    my $blocksep = '';
    my $block_num = 0;
    while( $expression =~ /$blocksep/ )
    {
        $blocksep = sprintf '__BLOCK_%s_%%s__', $block_num++;
    }
    
    my $self = bless {
        'block_counter' => 0
        , 'blocks' => {}
        , 'block_ph' => $blocksep
    }, $proto;
    
    $self->{'expression'} = $self->_parse_expression(
        $self->_parse_brackets($expression)
        , 0
    );

    delete @{$self}{'blocks','block_ph','block_counter'};
    
    return $self;
}

sub _parse_brackets
{
    my $self = shift;
    my $expression = shift;
    
    while( $expression =~ s/\(([^()]+)\)/$self->_get_brackets_replacement($1)/ge ){};
    
    return $expression;
}

sub _get_brackets_replacement
{
    my $self = shift;
    my $expression = shift;
    my $key = sprintf $self->{'block_ph'}, $self->{'block_counter'}++;
    $self->{'blocks'}->{$key} = $self->_parse_expression($expression, 0);
    return $key;
}

sub _get_block_or_variable
{
    my $self = shift;
    my $token = shift;
    my $result = undef;
    
    if( exists $self->{'blocks'}->{$token} )    # sub-block
    {
        $result = $self->{'blocks'}->{$token};
        delete $self->{'blocks'}->{$token};
    }
    else
    {
        $result = DTL::Fast::Template::Variable->new($token);
    }
    return $result;
}

sub _parse_expression
{
    my $self = shift;
    my $expression = shift;
    my $level = shift;
    my $operators = $DTL::Fast::Template::Expression::Operator::PRIORITY->[$level];
    
    my $result = [];
#    warn "Parsing $expression level $level";
    my @expression = split /(?:^|\s+)($operators)(?:$|\s+)/, $expression;
#    warn "Parsed to:\n\t".join("\n\t", @expression);
    
    if( 
        scalar @expression == 1 
    )
    {
        if( $level < $#{$DTL::Fast::Template::Expression::Operator::PRIORITY} ) # seems nothing on this level
        {
            $result = $self->_parse_expression($expression[0], $level+1);
        }
        else
        {
            # suppose it's operand
            $result = $self->_get_block_or_variable($expression[0]);
        }
    }
    else
    {
        foreach my $token (@expression)
        {
            next if $token eq ''; 
            
            if( $token =~ /$operators/ ) # operation
            {
                push @$result, new DTL::Fast::Template::Expression::Operator($token);
            }
            elsif( $level < $#{$DTL::Fast::Template::Expression::Operator::PRIORITY} )  # operand or subexpression
            {
                push @$result, $self->_parse_expression($token, $level+1);
            }
            else # can be only operand
            {
                push @$result, $self->_get_block_or_variable($token);
            }
        }
    }
    return $result;
}

sub render
{
    my $self = shift;
    my $context = shift;
    my $value = shift;
    
    return $value;
}

1;