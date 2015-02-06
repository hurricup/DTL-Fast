package DTL::Fast;
use strict; use warnings FATAL => 'all'; 
use parent 'Exporter';
use Carp;
use Digest::MD5 qw(md5_hex);

use 5.010;
our $VERSION = '1.606'; # ==> ALSO update the version in the pod text below!

require XSLoader;
XSLoader::load('DTL::Fast', $VERSION);

use DTL::Fast::Template;
use DTL::Fast::Cache::Runtime;
use DTL::Fast::Cache::Serialized;

our $RUNTIME_CACHE;
our $SERIALIZED_CACHE;

our @EXPORT_OK;

# @todo Texts should be tossed by references
# @todo These should be done via Cache class which can work with last modified date

push @EXPORT_OK, 'get_template';
sub get_template
{
    my( $template_name, %kwargs ) = @_;
    
    croak  "Template name was not specified" 
        if not $template_name;

    croak "Template directories array was not specified"
        if
            not defined $kwargs{'dirs'}
            or ref $kwargs{'dirs'} ne 'ARRAY'
            or not scalar @{$kwargs{'dirs'}}
        ;

    my $cache_key = _get_cache_key( $template_name, %kwargs );

    my $template;

    $RUNTIME_CACHE //= DTL::Fast::Cache::Runtime->new();
    
    if( 
        $kwargs{'no_cache'}
        or not defined ( $template = $RUNTIME_CACHE->get($cache_key))
    )
    {
        $template = read_template($template_name, %kwargs );
        
        if( defined $template )
        {
            $RUNTIME_CACHE->put($cache_key, $template);
        }
        else
        {
            croak  sprintf( <<'_EOT_', $template_name, join("\n", @{$kwargs{'dirs'}}));
Unable to find template %s in directories: 
%s
_EOT_
        }
    }
   
    return $template;
}

sub _get_cache_key
{
    my( $template_name, %kwargs ) = @_;
    
    return md5_hex(
        sprintf( '%s:%s:%s:%s'
            , __PACKAGE__
            , $template_name
            , join( ',', @{$kwargs{'dirs'}} )
            , join( ',', @{$kwargs{'ssi_dirs'}//[]})
            # shouldn't we pass uri_handler here?
        )
    )
    ;
}

sub read_template
{
    my( $template_name, %kwargs ) = @_;
    
    my $template = undef;
    my $template_path = undef;

    croak "Template directories array was not specified"
        if not defined $kwargs{'dirs'}
            or not ref $kwargs{'dirs'}
            or not scalar @{$kwargs{'dirs'}}
        ;
    
    my $cache_key = _get_cache_key( $template_name, %kwargs );

    $SERIALIZED_CACHE //= DTL::Fast::Cache::Serialized->new();
    
    if( 
        $kwargs{'no_cache'}
        or not defined ( $template = $SERIALIZED_CACHE->get($cache_key))   # runtime serialized cache reading
    )
    {
        if( 
            $kwargs{'no_cache'}
            or not exists $kwargs{'cache'} 
            or not $kwargs{'cache'}
            or not $kwargs{'cache'}->isa('DTL::Fast::Cache')
            or not defined ($template = $kwargs{'cache'}->get($cache_key))
        )
        {
            ($template, $template_path) = _read_file($template_name, $kwargs{'dirs'});
            
            if( defined $template )
            {
                $kwargs{'file_path'} = $template_path;
                $template = DTL::Fast::Template->new( $template, %kwargs);
        
                $kwargs{'cache'}->put( $cache_key, $template )
                    if 
                        defined $template
                        and exists $kwargs{'cache'}
                        and $kwargs{'cache'}
                        and $kwargs{'cache'}->isa('DTL::Fast::Cache')
                    ;
            }
        }
        
        $SERIALIZED_CACHE->put($cache_key, $template)
            if defined $template;
    }
    
    if( defined $template )
    {
        $template->{'cache'} = $kwargs{'cache'} if $kwargs{'cache'};
        $template->{'url_source'} = $kwargs{'url_source'} if $kwargs{'url_source'};
    }
    
    return $template;
}

sub _read_file
{
    my $template_name = shift;
    my $dirs = shift;
    my $template;
    my $template_path;
    
    foreach my $dir (@$dirs)
    {
        $dir =~ s/[\/\\]+$//xgsi;
        $template_path = sprintf '%s/%s', $dir, $template_name;
        if( 
            -e $template_path
            and -f $template_path
            and -r $template_path
        )
        {
            $template = __read_file( $template_path );
            last;
        }        
    }
    
    return ($template, $template_path);
}


sub __read_file
{
    my( $file_name ) = @_;
    my $result;
    
    if( open my $IF, '<', $file_name )
    {
        local $/ = undef;
        $result = <$IF>;
        close $IF;
    }
    else
    {
        croak  sprintf(
            'Error opening file %s, %s'
            , $file_name
            , $!
        );
    }
    return $result;
}

# result should be cached with full list of params
push @EXPORT_OK, 'select_template';
sub select_template
{
    my( $template_names, %kwargs ) = @_;
    
    croak  "First parameter must be a template names array reference" 
        if(
            not ref $template_names
            or ref $template_names ne 'ARRAY'
            or not scalar @$template_names
        );

    my $result = undef;
    
    foreach my $template_name (@$template_names)
    {
        if( ref ( $result = get_template( $template_name, %kwargs )) eq 'DTL::Fast::Template' )
        {
            last;
        }
    }
    
    return $result;
}

1;

__END__ 
=head1 NAME

DTL::Fast - Perl implementation of Django templating language.

=head1 VERSION

Version 1.606

=head1 SYNOPSIS

Complie and render template from code:

    use DTL::Fast;
    my $tpl = DTL::Fast::Template->new('Hello, {{ username }}!');
    print $tpl->render({ username => 'Alex'});
    
Or create a file: template.txt in /home/alex/templates with contents:

    Hello, {{ username }}!
    
And load and render it:

    use DTL::Fast qw( get_template );
    my $tpl = get_template( 'template.txt', ['/home/alex/templates'] );
    print $tpl->render({ username => 'Alex'});

=head1 DESCRIPTION

This module is a Perl and stand-alone templating system, cloned from Django templating sytem, described in L<here|https://docs.djangoproject.com/en/1.7/topics/templates/>.

=head2 GOALS

Goals of this implementation are:

=over

=item * Speed in mod_perl/FCGI environment

=item * Possibility to cache using files/memcached

=item * Maximum compatibility with original Django templates

=back

=head2 CURRENT STATUS

Current release implements almost all tags and filters documented on Django site.

There are no speed optimizations done yet.

Internationalization, localization and caching are not yet implemented.

=head1 PERL SIDE

You may get template object using three ways. 

=head2 Constructor


Using DTL::Fast::Template constructor:

    use DTL::Fast;
    
    my $tpl = DTL::Fast::Template->new(
        $template_text,                             # template itself
        'dirs' => [ $dir1, $dir2, ... ],            # optional, directories list to look for parent templates and includes
        'ssi_dirs' => [ $ssi_dir1, $ssi_dir1, ...]  # optional, directories list allowed to used in ssi tag (ALLOWED_INCLUDE_ROOTS in Django)
        'url_source' => \&uri_getter                # optional, reference to a function, that can return url template by model name (necessary for url tag)
    );

=head2 get_template
    
    use DTL::Fast qw(get_template);
    
    my $tpl = get_template(
        $template_path,                             # path to the template, relative to directories from second argument
        'dirs' => [ $dir1, $dir2, ... ],            # mandatory, directories list to look for parent templates and includes
        'ssi_dirs' => [ $ssi_dir1, $ssi_dir1, ...]  # optional, directories list allowed to used in ssi tag (ALLOWED_INCLUDE_ROOTS in Django)
        'url_source' => \&uri_getter                # optional, reference to a function, that can return url template by model name (necessary for url tag)
    );
    
when you are using C<get_template> helper function, framework will try to find template in following files: C<$dir1/$template_path, $dir2/$template_path ...> Searching stops on first occurance.

=head2 select_template

    use DTL::Fast qw(select_template);
    
    my $tpl = select_template(
        [ $template_path1, $template_path2, ...],   # paths to templates, relative to directories from second argument
        'dirs' => [ $dir1, $dir2, ... ],            # mandatory, directories list to look for parent templates and includes
        'ssi_dirs' => [ $ssi_dir1, $ssi_dir1, ...]  # optional, directories list allowed to used in ssi tag (ALLOWED_INCLUDE_ROOTS in Django)
        'url_source' => \&uri_getter                # optional, reference to a function, that can return url template by model name (necessary for url tag)
    );
    
when you are using C<select_template> helper function, framework will try to find template in following files: C<$dir1/$template_path1, $dir1/$template_path2 ...> Searching stops on first occurance.

=head2 render

After parsing template using one of the methods above, you may render it using context. Context is basically a hash of values, that will be substituted into template. Hash may contains scalars, hashes, arrays, objects and methods. Into C<render> method you may pass a Context object or just a hashref (in which case Context object will be created automatically).

    use DTL::Fast qw(get_template);
    
    my $tpl = get_template(
        'hello_template.txt',          
        'dirs' => [ '/srv/wwww/templates/' ]
    );
    
    print $tpl->render({ name => 'Alex' });
    print $tpl->render({ name => 'Ivan' });
    print $tpl->render({ name => 'Sergey' });

or

    use DTL::Fast qw(get_template);
    
    my $tpl = get_template(
        'hello_template.txt',          
        'dirs' => [ '/srv/wwww/templates/' ]
    );
    
    my $context = DTL::Fast::Context->new({
        'name' => 'Alex'
    });
    print $tpl->render($context);
    
    $context->set('name' => 'Ivan');
    print $tpl->render($context);

    $context->set('name' => 'Sergey');
    print $tpl->render($context);

=head2 Cache classes

To do...

=head2 Custom tags

To do...

=head2 Custom filters

To do...

    
=head1 TEMPLATING LANGUAGE

=head2 Tags

This module supports almost all built-in tags documented on L<official Django site|https://docs.djangoproject.com/en/1.7/ref/templates/builtins/#built-in-tag-reference>. Don't forget to read L<incompatibilities|/INCOMPATIBILITIES WITH DJANGO TEMPLATES> and L<extensions|/EXTENSIONS OF DJANGO TEMPLATES> sections.

=head3 firstofdefined

New tag, that works like C<firstof> tag, but checks if value is defined (not true)

=head3 url

C<url> tag works a different way. Because there is no framework around, we can't obtain model's path the same way. But you may pass C<url_source> parameter into template constructor or C<get_template>/C<select_template> function. This parameter MUST be a reference to a function, that will return to templating engine url template by some 'model path' (first parameter of C<url> tag). Second parameter passed to the C<url_source> handler will be a reference to array of argument values (in case of positional arguments) or reference to a hash of arguments (in case of named ones). Url source handler may just return a regexp template by model path and templating engine will try to restore it with specified arguments. Or, you may restore it yourself, alter replacement arguments or do whatever you want. 

=head2 Filters

This module supports all built-in filters documented on L<official Django site|https://docs.djangoproject.com/en/1.7/ref/templates/builtins/#built-in-filter-reference>. Don't forget to read L<incompatibilities|/INCOMPATIBILITIES WITH DJANGO TEMPLATES> and L<extensions|/EXTENSIONS OF DJANGO TEMPLATES> sections.

=head1 INCOMPATIBILITIES WITH DJANGO TEMPLATES

=over

=item * Django's setting C<ALLOWED_INCLUDE_ROOTS> should be passed to tempalte constructor/getter as C<ssi_dirs> argument.

=item * C<csrf_token> tag is not implemented, too well connected with Django.

=item * C<_dtl_*> variable names in context are reserved for internal system purposes. Don't use them.

=item * output from following tags: C<cycle>, C<firstof>, C<firstofdefined> are being escaped by default (like in later versions of Django)

=item * C<escapejs> filter works other way. It's not translating every non-ASCII character to the codepoint, but just escaping single and double quotes and C<\n \r \t \0>. Utf-8 symbols are pretty valid for javascript/json.

=item * C<fix_ampersands> filter is not implemented, because it's marked as depricated and will beremoved in Django 1.8

=item * C<pprint> filter is not implemented.

=item * C<iriencode> filter works like C<urlencode> for the moment.

=item * C<urlize> filter takes well-formatted url and makes link with this url and text generated by urldecoding and than escaping url link.

=item * wherever filter in Django returns C<True/False> values, C<DTL::Fast> returns C<1/0>.

=item * C<url> tag works a different way. Because there is no framework around, we can't obtain model's path the same way. But you may pass C<url_source> parameter into template constructor or C<get_template>/C<select_template> function. This parameter MUST be a reference to a function, that will return to templating engine url template by some 'model path' (first parameter of C<url> tag). Second parameter passed to the C<url_source> handler will be a reference to array of argument values (in case of positional arguments) or reference to a hash of arguments (in case of named ones). Url source handler may just return a regexp template by model path and templating engine will try to restore it with specified arguments. Or, you may restore it yourself, alter replacement arguments or do whatever you want. 

=back

=head1 EXTENSIONS OF DJANGO TEMPLATES

May be some of this features implemented in Django itself. Let me know about it.

=over

=item * filters may accept several arguments, and context variables can be used in them, like {{ var|filter1:var2:var3:...:varn }}

=item * C<numberformat> - new filter. Formats number like C<12 345 678.9999999> 

=item * C<strftime> - new filter. Formats time using L<C<Date::Format>> module, which is using C functions C<strftime> and C<ctime>.

=item * C<firstofdefined> - new tag, that works like C<firstof> tag, but checks if value is defined (not true)

=item * C<defined> logical operator. In logical constructions you may use C<defined> operator, which works exactly like perl's C<defined>

=item * alternatively, in logical expresisons you may compare (==,!=) value to C<undef> or C<None> which are synonims

=item * C<slice> filter works with ARRAYs and HASHes. Arrays slicing supports Python's indexing rules and Perl's indexing rules (but Perl's one has no possibility to index from the end of the list). Hash slicing options should be a comma-separated keys.

=item * You may use brackets in logical expressions to override natural precedence

=item * C<forloop> context hash inside a C<for> block tag contains additional fields: C<odd>, C<odd0>, C<even> and C<even0>

=item * variables rendering: if any code reference encountered due variable traversing, is being invoked with context argument. Like:

    {{ var1.key1.0.func.var2 }} 
    
is being rendered like: 

    $context->{'var1'}->{'key1'}->[0]->func($context)->{'var2'}

=item * you may use filters with static variables. Like:

    {{ "text > test"|safe }}

=item * objects behaviour methods. You may extend your objects, stored in context to make them work properly with some tags and operations:

=over

=item * C<as_bool>           - returns logical representation of object

=item * C<and(operand)>      - makes logical `and` between object and operand

=item * C<or(operand)>       - makes logical `or` between object and operand

=item * C<div(operand)>      - divides object by operand

=item * C<equal(operand)>    - checks if object is equal with operand

=item * C<compare(operand)>  - compares object with operand, returns -1, 0, 1 on less than, equal or greater than respectively

=item * C<in(operand)>       - checks if object is in operand

=item * C<contains(operand)> - checks if object contains operand

=item * C<minus(operand)>    - substitutes operand from object

=item * C<plus(operand)>     - adds operand to object

=item * C<mod(operand)>      - returns reminder from object division to operand

=item * C<mul(operand)>      - multiplicates object by operand

=item * C<pow(operand)>      - returns object powered by operand

=item * C<not()>             - returns object inversion

=item * C<reverse()>         - returns reversed object

=item * C<as_array()>        - returns array representation of object

=item * C<as_hash()>        - returns hash representation of object

=back 

=back

=head1 BENCHMARKS

I've compared module speed with previous abandoned implementation: L<C<Dotiac::DTL>> in both modes: FCGI and CGI. Test template and scripts are in /timethese directory.
Django templating in Python with cache works about 80% slower than C<DTL::Fast>.

=head2 FCGI/mod_perl

Template parsing permormance with software cache wiping on each iteration:

    Benchmark: timing 5000 iterations of DTL::Fast  , Dotiac::DTL...
    
    DTL::Fast  :  3 wallclock secs ( 2.47 usr +  1.05 sys =  3.51 CPU) @ 1424.10/s (n=5000)
    Dotiac::DTL: 44 wallclock secs (21.86 usr + 20.39 sys = 42.25 CPU) @ 118.36/s (n=5000)

C<DTL::Fast> parsing templates 12 times faster, than L<C<Dotiac::DTL>>.

To run this test, you need to alter L<C<Dotiac::DTL>> module and change declaration of C<my %cache;> to C<our %cache;>. 
    
Rendering of pre-compiled template (software cache):

    Benchmark: timing 3000 iterations of DTL::Fast  , Dotiac::DTL...

    DTL::Fast  : 18 wallclock secs (13.84 usr +  4.32 sys = 18.16 CPU) @ 165.22/s (n=3000)
    Dotiac::DTL: 18 wallclock secs (17.85 usr +  0.00 sys = 17.85 CPU) @ 168.10/s (n=3000)

Tests shows, that C<DTL::Fast> works a bit slower, than L<C<Dotiac::DTL>> in persistent environment.

=head2 CGI

This test rendered test template many times by external script, invoked via C<system> call:

    Benchmark: timing 300 iterations of Dotiac render     , Fast cached render, Fast render
    
    Dotiac render     : 40 wallclock secs ( 0.11 usr +  0.40 sys =  0.51 CPU) @ 583.66/s (n=300)
    Fast render       : 55 wallclock secs ( 0.06 usr +  0.42 sys =  0.48 CPU) @ 619.83/s (n=300)

Tests shows, that C<DTL::Fast> works 40% slower, than L<C<Dotiac::DTL>> in CGI environment.

=head2 DTL::Fast steps performance

    1 Cache key  :  0 wallclock secs ( 0.19 usr +  0.00 sys =  0.19 CPU) @ 534759.36/s (n=100000)
    2 Decompress :  0 wallclock secs ( 0.27 usr +  0.00 sys =  0.27 CPU) @ 377358.49/s (n=100000)
    3 Serialize  :  4 wallclock secs ( 3.73 usr +  0.00 sys =  3.73 CPU) @ 26824.03/s (n=100000)
    4 Deserialize:  5 wallclock secs ( 4.26 usr +  0.00 sys =  4.26 CPU) @ 23479.69/s (n=100000)
    5 Compress   : 10 wallclock secs (10.50 usr +  0.00 sys = 10.50 CPU) @ 9524.72/s (n=100000)
    6 Validate   : 11 wallclock secs ( 3.12 usr +  8.05 sys = 11.17 CPU) @ 8952.55/s (n=100000)

    7 Parse      :  1 wallclock secs ( 0.44 usr +  0.23 sys =  0.67 CPU) @ 1492.54/s (n=1000)
    8 Render     : 11 wallclock secs ( 9.30 usr +  1.14 sys = 10.44 CPU) @ 95.82/s (n=1000)    

=head1 SEE ALSO

=over

=item * Main project repository and bugtracker: L<https://github.com/hurricup/DTL-Fast>

=item * CPAN Testers reports: L<http://www.cpantesters.org/distro/D/DTL-Fast.html>

=item * Testers matrix: L<http://matrix.cpantesters.org/?dist=DTL-Fast>
        
=item * AnnoCPAN, Annotated CPAN documentation: L<http://annocpan.org/dist/DTL-Fast>

=item * CPAN Ratings: L<http://cpanratings.perl.org/d/DTL-Fast>

=item * Original Django templating documentation: L<https://docs.djangoproject.com/en/1.7/topics/templates/>

=item * Other implementaion: L<http://search.cpan.org/~maluku/Dotiac-0.8/lib/Dotiac/DTL.pm>

=back

=head1 LICENSE

This module is published under the terms of the MIT license, which basically means "Do with it whatever you want". For more information, see the LICENSE file that should be enclosed with this distributions. A copy of the license is (at the time of writing) also available at L<http://www.opensource.org/licenses/mit-license.php>.

=head1 AUTHOR

Copyright (C) 2014-2015 by Alexandr Evstigneev (L<hurricup@evstigneev.com|mailto:hurricup@evstigneev.com>)

=cut

