=pod

=head1 NAME

Regexp::Bind - Bind variables to captured buffers 

=head1 SYNOPSIS

  use Regexp::Bind qw(
                      bind
                      global_bind
                     );

  $record = bind($string, $regexp, @fields);
  @record = global_bind($string, $regexp, @fields);

  $record = bind($string, $embedded_regexp);
  @record = global_bind($string, $embedded_egexp);


=head1 DESCRIPTION

This module is an extension to perl's native regexp function. It binds an anonymous hash or named variables to matched buffers. Both normal regexp syntax and embedded regexp syntax are supported. You can view it as a tiny and petite data extraction system.

=head1 FUNCTIONS

Two functions are exported. They bind the given fields to captured contents, and return an anonymous hash of the fields.


=head2 Match the first occurrence

  use Data::Dumper;

  $record = bind($string, $regexp, qw(field_1 field_2 field_3));
  print Dumper $record;

=head2 Do global matching and store matched parts in @record 

  @record = global_bind($string, $regexp, qw(field_1 field_2 field_3));
  print Dumper $_ foreach @record;

=head1 NAMED VARIABLE BINDING

To use named variable binding, please set $Regexp::Bind::USE_NAMED_VAR to non-undef, and then matched parts will be bound to named variables while using bind(). It is not supported for global_bind().

  $Regexp::Bind::USE_NAMED_VAR = 1;
  bind($string, $regexp, qw(field_1 field_2 field_3));
  print "$field_1 $field_2 $field_3\n";


=head1 EMBEDDED REGEXP

Using embedded regexp syntax means you can embed fields right in regexp itself. Its embedded syntax exploits the feature of in-line commenting in regexps.

The module first tries to detect if embedded syntax is used. If detected, then comments are stripped and regexp is turned back to a simple one.

Using embedded syntax, field's name is restricted to B<alphanumerics> only.

Example:

  bind($string, qr'# (?#<field_1>\w+) (?#<field_2>\d+)\n'm);

is converted into

  bind($string, qr'# (\w+) (\d+)\n'm);

If embedded syntax is detected, further input arguments are ignored. It means that

  bind($string, qr'# (?#<field_1>\w+) (?#<field_2>\d+)\n'm,
       qw(field_1 field_2));

is the same as

  bind($string, qr'# (?#<field_1>\w+) (?#<field_2>\d+)\n'm);

or

  bind($string, qr'# (\w+) (\d+)\n'm);


Note that the module simply replaces B<(?#E<lt>field nameE<gt>> with B<(> and binds the field's name to buffer. It does not check for syntax correctness, so any fancier usage may crash.

=head1 SEE ALSO

For a similar functionality, see L<Regexp::Fields>.

See also test.pl for an example.

=cut

package Regexp::Bind;
use 5.006;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(bind global_bind global_bind);
our $VERSION = '0.02';

our $USE_NAMED_VAR = 0;
use strict;
no strict 'refs';
sub bind {
    my $string = shift || die "No string input";
    my $regexp = shift || die "No regexp input";

    my @field;
    while($regexp =~ s,\(\?#<(\w+?)>,(,o){
      push @field, $1;
    }
    @field = @_ unless @field;

    $string =~ m/$regexp/;
    my $cnt = 1;
    if($USE_NAMED_VAR){
	my $pkg = (caller)[0];
	foreach my $field (@field){
	    ${"${pkg}::$field"} = ${$cnt++};
	}
    }
    else {
      +{
	map{ $_ => ${$cnt++} } @field
       };
    }
}


sub global_bind {
    my $string = shift || die "No string input";
    my $regexp = shift || die "No regexp input";

    my @field;
    while($regexp =~ s,\(\?#<(\w+?)>,(,o){
      push @field, $1;
    }
    @field = @_ unless @field;

    my @bind;
    my $cnt;
    while($string =~ m/$regexp/g){
      $cnt = 1;
      push @bind,
	+{
	  map{ $_ => ${$cnt++} } @field
	 };
    }
    wantarray ? @bind : \@bind;
}

1;
__END__



=head1 COPYRIGHT

Copyright (C) 2004 by Yung-chung Lin (a.k.a. xern) <xern@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself

=cut
