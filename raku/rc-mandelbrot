constant SQUISH = 1.5;

sub MAIN(Int $w = 31, Int $max_iterations = 50) {
    my $h = round($w / SQUISH);

    my ($re_min, $re_max) = (-2,   1/2);
    my ($im_min, $im_max) = (-5/4, 5/4);

    my $re_step = ($re_max - $re_min) / ($w - 1);
    my $im_step = ($im_max - $im_min) / ($h - 1);

    # Allow SCALE == 0 for compile time testing
    exit(0) if $w < 2;

    my @color_map = ' ', < . , ; * $ # @ >;

    my sub mandelbrot($c) {
        my $z = $c;
        for 1 .. $max_iterations {
            $z = $z * $z + $c;
            return $_ if abs($z) > 2;
        }
        0;
    }

    loop (my $y = $im_max; $y >= $im_min; $y -= $im_step) {
        loop (my $x = $re_min; $x <= $re_max; $x += $re_step) {
            my $iter = mandelbrot($x + $y * i);
            print @color_map[$iter % @color_map];
        }
        print "\n"
    }
}
