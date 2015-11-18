sub MAIN(Int $h = 64, Int $w = 64, Int $spins = 64) {
    my @spinner = < | / - \\ >;

    for ^$h {
        for ^$w {
            print ".";
            for ^$spins {
                print "\b@spinner[$_ % @spinner]";
            }
            print "\b.";
        }
        print ".\n";
    }
}
