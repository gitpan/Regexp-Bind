use Test::More qw(no_plan);
use ExtUtils::testlib;
use Data::Dumper;
use Regexp::Bind qw(bind global_bind global_arraybind);


$quotes =<<'.';
"Anyone can escape into sleep, we are all geniuses when we dream, the butcher's the poet's equal there."
-E. M. Cioran, The Tempation to Exist
"We all dream; we do not understand our dreams, yet we act as if nothing strange goes on in our sleep minds, strange at least by comparison with the logical, purposeful doings of our minds when we are awake."
-Erich Fromm, The Forgotten Language
"One of the most adventurous things left us is to go to bed. For no one can lay a hand on our dreams."
-E. V. Lucas, 365 Days and One More
.

######################################################################

$template = qr'"(.+?)"\n-(.+?), (.+?)\n's;

$record = bind($quotes, $template, qw(quote author from));
is($record->{author}, 'E. M. Cioran');

@record = global_arraybind($quotes, $template, qw(quote author from));
is($record[0]->{from}, 'The Tempation to Exist');
is($record[1]->{author}, 'Erich Fromm');
like($record[2]->{quote}, qr'adventurous');

while($record = global_bind($quotes, $template, qw(quote author from))){
    like($record->{quote}, qr'dream');
}

######################################################################
# use named variables
######################################################################
$Regexp::Bind::USE_NAMED_VAR = 1;
bind($quotes, $template, qw(quote author from));
like($quote, qr'dream');
like($author, qr'Cioran');
like($from, qr'Tempation');

while(global_bind($quotes, $template, qw(quote author from))){
    like($quote, qr'dream');
    like($author, qr'E');
    like($from, qr'a');
}
