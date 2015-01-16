use Benchmark qw(:all);

sub myshift{
    my $var1 = shift;
    my $var2 = shift;
    my $var3 = shift;
    my $var4 = shift;
    my $var5 = shift;
    my $var6 = shift;
    my %kwargs = @_;
    
    return;
}

sub myunpack{
    my( $var1, $var2, $var3, $var4, $var5, $var6, %kwargs) = @_;
    return;
}

timethese( 3000000, {
    'Shift' => sub{ myshift(1,2,3,1,2,3,'a' => 'b', 'c' => 123, 'd' => [1,2,3]); },
    'Unpack' => sub{ myunpack(1,2,3,1,2,3,'a' => 'b', 'c' => 123, 'd' => [1,2,3]); },
});