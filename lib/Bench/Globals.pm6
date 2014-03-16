module Bench::Globals;

our $PROGRAM_DIR    is export = ~($*PROGRAM_NAME ~~ /^(.*\/)/) || './';
our $COMPONENTS_DIR is export = "$PROGRAM_DIR/components";
our $TIMINGS_DIR    is export = "$PROGRAM_DIR/timings";

# This ends up getting used all over the place;
# might as well just load it at startup
our $COMPONENTS is export;
