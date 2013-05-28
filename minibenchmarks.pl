[
 {
  name  => 'rc-forest-fire',
  skip  => [qw( niecza.nqp p6.pl p6.js_v8 )],
  scale => 1 << 3,
  x_label => 'Frames per Run',
  y_label => 'Frames per Second',
  perl5 => [qw( BENCH/perl5/rc-forest-fire 16 16 SCALE )],
  perl6 => [qw( BENCH/perl6/rc-forest-fire 16 16 SCALE )],
  nqp   => [qw( BENCH/nqp/rc-forest-fire   16 16 SCALE )],
 },
 {
  name  => 'rc-man-or-boy-test',
  skip  => [qw( )],
  scale => 10,
  scaling => 'linear',
  x_label => 'k Parameter',
  perl5 => [qw( BENCH/perl5/rc-man-or-boy-test SCALE )],
  perl6 => [qw( BENCH/perl6/rc-man-or-boy-test SCALE )],
  nqp   => [qw( BENCH/nqp/rc-man-or-boy-test   SCALE )],
 },
]
