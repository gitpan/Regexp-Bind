use ExtUtils::MakeMaker;
WriteMakefile
    (
     'NAME'		=> 'Regexp::Bind',
     'VERSION_FROM'	=> 'Bind.pm', 
     'PREREQ_PM'	=> {
	 qw
	 (
	  Digest::MD5 2.27
	 )
     }, 
     ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Bind.pm', 
       AUTHOR     => 'xern <xern@cpan.org>') : ()),

);
