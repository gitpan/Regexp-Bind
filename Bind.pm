=pod

=head1 NAME

Regexp::Bind - Bind variables to captured buffers 

=head1 SYNOPSIS

  use Regexp::Bind qw(
                      bind
                      global_bind
                      global_arraybind
                     );

  $record = bind($string, $regexp, @fields);
  $record = global_bind($string, $regexp, @fields);
  @record = global_arraybind($string, $regexp, @fields);


=head1 DESCRIPTION

This module is an extension to perl's native regexp function. It binds matched variables to an anonymous hash or named variables. You can view it as a tiny and petite template extraction system.

Three functions are exported. They bind the given field names to captured contents, and return an anonymous hash to the fields.

  use Data::Dumper;

  # match the first occurrence
  $record = bind($string, $regexp, qw(field_1 field_2 field_3));
  print Dumper $record;

  # global matching
  while($record = global_bind($string, $regexp, qw(field_1 field_2 field_3));
    print Dumper $record;
  }

  # do global matching and store matched parts in @record 
  @record = global_arraybind($string, $regexp, qw(field_1 field_2 field_3));
  print Dumper $_ foreach @record;

To use named variable binding, please set $Regexp::Bind::USE_NAMED_VAR to non-undef, and then matched parts will be binded to named variables while using bind() and global_bind(). It is not supported for global_arraybind().

  $Regexp::Bind::USE_NAMED_VAR = 1;
  bind($string, $regexp, qw(field_1 field_2 field_3));
  print "$field_1 $field_2 $field_3\n";

  while( global_bind($string, $regexp, qw(field_1 field_2 field_3) ){
    print "$field_1 $field_2 $field_3\n";
  }


See also L<test.pl> for an example.

For a similar functionality, see L<Regexp::Fields>. But I don't really like that style messing up with regexp itself, so I built up this module.

=cut

package Regexp::Bind;
use 5.006;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(bind global_bind global_arraybind);
our $VERSION = '0.01';

our $USE_NAMED_VAR = 0;

sub bind {
    my $string = shift;
    my $regexp = shift;
    $string =~ m/$regexp/;
    my $cnt = 1;
    if($USE_NAMED_VAR){
	my $pkg = (caller)[0];
	foreach my $field (@_){
	    ${"${pkg}::$field"} = ${$cnt++};
	}
    }
    else {
      +{
	map{ $_ => ${$cnt++} } @_
       };
    }
}

use Digest::MD5 qw(md5);
our $string_digest;
our $string_pos;
sub global_bind {
    my $string = shift;
    my $regexp = shift;
    my $digest = md5 $string;
    if($digest ne $string_digest){
      $string_digest = $digest;
      pos($string) = 0;
    }
    else{
      pos($string) = $string_pos;
    }

    my $cnt;
    while($string =~ m/$regexp/g){
      $string_pos = pos($string);

      $cnt = 1;
      if($USE_NAMED_VAR){
	my $pkg = (caller)[0];
	foreach my $field (@_){
	  ${"${pkg}::$field"} = ${$cnt++};
	}
	return 1;
      }
      else {
	return
	  +{
	    map{ $_ => ${$cnt++} } @_
	   };
      }
    }
    $string_pos = 0;
    0;
}

sub global_arraybind {
    my $string = shift;
    my $regexp = shift;
    my @bind;
    my $cnt;
    while($string =~ m/$regexp/g){
      $cnt = 1;
      push @bind,
	+{
	  map{ $_ => ${$cnt++} } @_
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
