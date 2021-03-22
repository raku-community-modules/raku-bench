%raku-bench: Tools to benchmark and compare Perl family language implementations

<!--

TABLE OF CONTENTS
-----------------
* REALLY QUICK START
* QUICK START
* NETWORK TRAFFIC
* BENCHMARKING TIPS
* PREREQUISITES
* COPYRIGHT

-->


REALLY QUICK START
------------------
1. Make sure you'll have a net connection and idle CPUs for the next few hours
2. Run a quickstart:
   a. If your primary goal is performance testing run: `./bench quickstart`
   b. If your primary goal is stress testing run:      `./bench quickstress`
3. Profit!


QUICK START
-----------
NOTE:  This is an EARLY RELEASE, and no attempt has been made to bulletproof
       the tools.  Play nice.  :-)

A sample sequence for building, benchmarking, and comparing a few
compilers is as follows:

    # First step chews network bandwidth to mirror repos; see next section
    ./bench setup

    # Benchmark several different compilers' May 2013 releases
    export CHECKOUTS='perl5/v5.18.0 nqp/2013.05 nqp-jvm/2013.05 rakudo/2013.05'
    ./bench extract $CHECKOUTS
    ./bench build   $CHECKOUTS
    ./bench time    $CHECKOUTS
    ./bench compare $CHECKOUTS


NETWORK TRAFFIC
---------------
raku-bench tries to front-load as much of the network traffic as possible,
so that you can run `./bench setup` once on a fast network, then disconnect
and do benchmarking to your heart's content without touching the network
again (unless you run `./bench fetch` to bring in new upstream commits).

During the setup process, `bench` clones a bare mirror of the git repos of
every component it knows about.  After that, the extract command simply
makes local clones of these bare mirrors as needed, not touching the network
at all.  Also, special care is taken during component builds so that
components such as NQP and Rakudo that want to automatically clone other
components during build don't do so over the network, making fast local
clones instead.

Thus, after setup you can build, benchmark, and analyze without touching the
network again.  Eventually though you may want to grab the latest changes to
the component repos, e.g. to benchmark a new release when it comes out.  You
can do this with `./bench fetch`, which takes care to only update the bare
mirrors across the network -- not requiring nearly as much bandwidth as the
original setup since only new commits and tags are pulled -- and then update
all extracted checkouts locally from those mirrors.


BENCHMARKING TIPS
-----------------
Make sure you stop background processes when benchmarking!  Mail programs,
web browsers, media players, and server applications of many types are
particularly suspect.  They tend to use lots of CPU and memory, run heavy
background tasks at both regular and irregular intervals, and often chew a
fair amount of I/O and cache capacity as well.  This will *strongly* affect
the benchmark results.

Memory usage can be particularly important.  The benchmarks are tuned to
work within the memory footprint of a 32-bit machine with 2 GiB RAM or a
64-bit machine with 3 GiB RAM.  However, running a mail client and a web
browser at the same time when memory is already tight can result in heavy
swapping, which will produce useless results (VERY SLOWLY to boot).


PREREQUISITES
-------------
You will need at least perl5 5.10.x, with the following modules installed:

    Data::Alias
    DateTime
    IPC::Run
    JSON
    JSON::XS (best) or JSON::PP (slower)
    List::MoreUtils

You will need a Raku compiler to run the `bench` interface (though you can
benchmark the tests "manually" using the raw `timeall` and `analyze` Perl 5
scripts in a pinch).  The author generally uses bleeding-edge Rakudo, but any
Rakudo as of 2013.04 or later should do.  Patches welcomed to make `bench`
work well with other Raku compilers.

Your Raku compiler will need the following modules installed:

    JSON::Tiny
    Shell::Command

If you have `zef` installed, you should already have these, as they are
installed during the `zef` boostrap procedure.

Paths to the proper working directory of compilers not yet handled by the
`./bench extract` mechanism can be set in the %COMPILERS hash at the top
of the `timeall` script.  The default directories are assumed to be created
by extract, or in parallel checkouts at the same directory level as the
raku-bench checkout.

Compilers tested so far:

    Perl
        perl
    Raku
        rakudo
    NQP
        nqp
        rakudo

Enjoy!


COPYRIGHT
---------

raku-bench is Copyright 2012-2014, Geoffrey Broadwell.  This project is
open source, and may be used, copied, modified, distributed, and redistributed
under the terms of the
[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0) .

The `jqplot/` directory contains selected files from the jqPlot and jQuery
projects; copyright details may be found in `jqplot/copyright.txt` .

Some benchmarks have been based on other open-source programs; in particular,
benchmarks named with a leading `rc-` prefix were modified from versions found
on [Rosetta Code](http://rosettacode.org/wiki/Rosetta_Code) which licenses all
content under the
[GNU Free Documentation License 1.2](http://www.gnu.org/licenses/fdl-1.2.html) .
