=pod

=head1 NAME

Regexp::Bind - Bind variables to captured buffers 

=head1 SYNOPSIS

  use Regexp::Bind qw(
                      bind global_bind
                      bind_array global_bind_array
                     );

  $record = bind($string, $regexp, @fields);
  @record = global_bind($string, $regexp, @fields);

  $record = bind_array($string, $regexp);
  @record = global_bind_array($string, $regexp);

  $record = bind($string, $embedded_regexp);
  @record = global_bind($string, $embedded_egexp);


=head1 DESCRIPTION

This module is an extension to perl's native regexp function. It binds anonymous hashes or named variables to matched buffers. Both normal regexp syntax and embedded regexp syntax are supported. You can view it as a tiny and petite data extraction system.

=head1 FUNCTIONS

Two types of function are exported. They bind the given fields to captured contents, and return anonymous hashes/arrayes of the fields.


=head2 Match the first occurrence

  use Data::Dumper;

=head3 Binding to anonymous hash

  $record = bind($string, $regexp, qw(field_1 field_2 field_3));
  print Dumper $record;

=head3 Binding to array

  $record = bind_array($string, $regexp);
  print $record->[0];

=head2 Do global matching and store matched parts in @record 

=head3 Binding to anonymous hash

  @record = global_bind($string, $regexp, qw(field_1 field_2 field_3));
  print Dumper $_ foreach @record;

=head3 Binding to array

  @record = global_bind_array($string, $regexp);
  print $record[0]->[0];

=head1 NAMED VARIABLE BINDING

To use named variable binding, please set $Regexp::Bind::USE_NAMED_VAR to non-undef, and then matched parts will be bound to named variables while using bind(). It is not supported for global_bind(), bind_array() and global_bind_array().

  $Regexp::Bind::USE_NAMED_VAR = 1;
  bind($string, $regexp, qw(field_1 field_2 field_3));
  print "$field_1 $field_2 $field_3\n";


=head1 EMBEDDED REGEXP

Using embedded regexp syntax means you can embed fields right in regexp itself. Its embedded syntax exploits the feature of in-line commenting in regexps.

The module first tries to detect if embedded syntax is used. If detected, then comments are stripped and regexp is turned back into a simple one.

Using embedded syntax, for the sake of simplicity and legibility, field's name is restricted to B<alphanumerics> only. bind_array() and global_bind_array() do not support embedded syntax.


Example:

  bind($string, qr'# (?#<field_1>\w+) (?#<field_2>\d+)\n'm);

is converted into

  bind($string, qr'# (\w+) (\d+)\n'm);

If embedded syntax is detected, further input arguments are ignored. It means that

  bind($string, qr'# (?#<field_1>\w+) (?#<field_2>\d+)\n'm,
       qw(field_1 field_2));

is the same as

  bind($string, qr'# (?#<field_1>\w+) (?#<field_2>\d+)\n'm);

and conceptually equal to

  bind($string, qr'# (\w+) (\d+)\n'm, qw(field_1 field_2));



Note that the module simply replaces B<(?#E<lt>field nameE<gt>> with B<(> and binds the field's name to buffer. It does not check for syntax correctness, so any fancier usage may crash.

=cut

package Regexp::Bind;
use 5.006;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(bind global_bind bind_array global_bind_array);
our $VERSION = '0.03';

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

sub bind_array {
   my $string = shift || die "No string input";
   my $regexp = shift || die "No regexp input";
   [ ($string =~ m/$regexp/) ];
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

sub global_bind_array {
   my $string = shift || die "No string input";
   my $regexp = shift || die "No regexp input";
   my @bind;
   push @bind, [ map { ${$_} } 1..$#+ ] while $string =~ m/$regexp/g;
   @bind;
}

1;
__END__

=head1 SEE ALSO

For a similar functionality, see L<Regexp::Fields>.

And see L<Template::Extract> and L<WWW::Extractor> also. They are similar projects with prettier templates instead of low-level regexps.

You may wanna check test.pl for an example too.

=head1 TO DO

Perhaps, I'll add a 'FOREACH' directive like that in L<Template::Extract>, or implement basic inline buffer filtering, and then you don't need to write m// and s/// plus map() and grep() outside of regexps.


=head1 COPYRIGHT

Copyright (C) 2004 by Yung-chung Lin (a.k.a. xern) <xern@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself

=cut
