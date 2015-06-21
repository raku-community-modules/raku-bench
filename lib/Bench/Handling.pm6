unit module Bench::Handling;

use Bench::Globals;
use JSON::Tiny;
use Shell::Command;

our sub go_to_bench_dir() is export {
    # Reduce directory insanity a bit by changing to bench root
    # and eliminating hardcoding for generated subdir names
    chdir $PROGRAM_DIR;
    $PROGRAM_DIR    = $*CWD;
    $COMPONENTS_DIR = "$PROGRAM_DIR/components";
    $TIMINGS_DIR    = "$PROGRAM_DIR/timings";
}

our sub init_bench_handling() is export {
    $COMPONENTS = from-json(slurp "$PROGRAM_DIR/components.json");
}

#| Check whether components dir exists and bail out if not (recommending 'setup' command)
our sub needs-setup ($action) is export {
    unless $COMPONENTS_DIR.IO.d {
        print qq:to/COMPONENTS/;
            There is no '{ $COMPONENTS_DIR.IO.basename }' tree, and thus there are no repos to $action.
            Please run: `$*PROGRAM_NAME setup`.
            COMPONENTS
        exit 1;
    }
}

#| Check whether timings dir exists and bail out if not (recommending steps to produce timings)
our sub needs-timings ($action) is export {
    unless $TIMINGS_DIR.IO.d {
        print qq:to/TIMINGS/;
            There is no '{ $TIMINGS_DIR.IO.basename }' tree, and thus there are no timings to $action.
            Please run:
            `$*PROGRAM_NAME setup`   to prepare and clone components,
            `$*PROGRAM_NAME extract` to extract Perls to be benchmarked,
            `$*PROGRAM_NAME build`   to build the Perls and their components, and
            `$*PROGRAM_NAME time`    to benchmark the built Perls and generate timings.
            TIMINGS
        exit 1;
    }
}

#| Convert pairs to command line option strings
our sub as-options (*%args) is export {
    my @options;
    for %args.kv -> $k, $v {
        given $v {
            when !.defined {}
            when Bool      { @options.push: $v ?? "--$k" !! "--no$k" }
            default        { @options.push: "--$k=$v"                }
        }
    }

    return @options;
}

#| Simulate the behavior of `git clean -dxf`
our sub rmtree ($dir, :$noisy = True) is export {
    return unless $dir.IO.d;
    say "Removing $dir" if $noisy;
    rm_rf $dir;
}

#| Run code for every requested component
our sub for-components (@components, &code, :$quiet) is export {
    for explode-components(@components) -> $comp {
        my $name = $comp<info><name>;
        say "==> $name" unless $quiet;

        code($comp, $name);
    }
}

#| Run code for every checkout in every requested component
our sub for-checkouts (@components, &code, :$quiet) is export {
    for-components @components, -> $comp, $name {
        for $comp<checkouts>.list -> $checkout {
            say "----> $checkout" unless $quiet;

            code($comp, $name, $checkout);
        }
    }, :$quiet;
}

#| Expand a partially-specified list of components and checkouts
our sub explode-components (@component-specs, :$chdir = True, :$default-to-dirs = True) is export {
    chdir $COMPONENTS_DIR if $chdir;
    @component-specs ||= dir($COMPONENTS_DIR).sort if $default-to-dirs;

    my @exploded;
    for @component-specs -> $spec is copy {
        # Remove optional leading "$COMPONENTS_DIR/", which helps with tab completion
        $spec .= subst(/^ $COMPONENTS_DIR '/' /, '');  # ' -- Dang syntax highlighting
        die "Don't know what to do with empty component specification" unless $spec.chars;

        my ($component, $checkouts) = $spec.split: '/';
        my $comp-info = $COMPONENTS{$component};
        die "Don't know how to process component '$component'" unless $comp-info;

        my @checkouts;
        if $checkouts.defined && $checkouts.chars {
            @checkouts = $checkouts.split: ',';
        }
        else {
            my $bare   = "$component.git";
            @checkouts = dir("$COMPONENTS_DIR/$component")\
                         .map(*.basename).grep(none($bare)).sort;
        }

        if @exploded.first(*.<info><name> eq $component) -> $comp {
            $comp<checkouts>.push: |@checkouts;
        }
        else {
            @exploded.push: { info => $comp-info, checkouts => @checkouts };
        }
    }

    return @exploded;
}

#| Expand a partially-specified list of timings files
our sub explode-timings (@timing-specs, :$chdir = True, :$default-to-dirs = True) is export {
    chdir $TIMINGS_DIR if $chdir;
    @timing-specs ||= dir($TIMINGS_DIR).sort if $default-to-dirs;

    my %exploded;
    for @timing-specs -> $spec is copy {
        # Remove optional leading "$TIMINGS_DIR/", which helps with tab completion
        $spec .= subst(/^ $TIMINGS_DIR '/' /, '');  # ' -- Dang syntax highlighting
        die "Don't know what to do with empty timing specification" unless $spec.chars;

        my ($component, $files) = $spec.split: '/';

        my @files;
        if $files.defined && $files.chars {
            @files = $files.split(',').map: { /'.json' $/ ?? $_ !! $_ ~ '.json' };
        }
        else {
            @files = dir("$TIMINGS_DIR/$component",
                         test => /'.json' $/).map(*.basename.Str).sort;
        }

        %exploded{$component}.push: |@files;
    }

    return %exploded;
}
