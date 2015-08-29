unit module Bench::Globals;

our $PROGRAM-DIR    is export = $*PROGRAM-NAME.IO.dirname;
our $COMPONENTS_DIR is export = "$PROGRAM-DIR/components";
our $TIMINGS_DIR    is export = "$PROGRAM-DIR/timings";

# This ends up getting used all over the place;
# might as well just load it at startup
our $COMPONENTS is export;
