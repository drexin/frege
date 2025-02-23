#!perl -w

use warnings;
use strict;

my $n = 3;

sub mkFun {
    my @args = @_;
    if (scalar @args > 1) {
        my $t1 = shift @args;
        my $t2 = mkFun(@args);
        return "Fun<$t1, $t2>";
    }
    else {
        return shift @args;
    }
}

while ($n < 27) {
    open J, ">frege/rt/Lam$n.java" or die "can't open $!";
    my @targs = map { "T$_" } (1..$n+1);
    my $ext = mkFun(@targs);
    my @xargs = map { "X$_" } (1..$n+1);
    my @nargs = map {"final Lazy<FV> arg$_" } (1..$n);
    my $cnargs = join (",", @nargs);
    my @args  = map { "arg$_" } (1..$n);
    my $crargs = join(",", reverse @args);
    my $rt = $targs[$n];
    my $ctargs = join (",", @targs);
    my $cxargs = join (",", @xargs);
    my $cargs  = join (",", @args);
    # my $crargs = join (",", reverse @args);
    my $p = $n-1;
    my @ptargs = @targs; shift @ptargs;
    my $cptargs = join(",", @ptargs);
    my @pargs = map { "final Lazy<FV> arg$_" } (2..$n);
    my @rpargs = reverse @pargs;
    my $crpargs = join(",", @rpargs);
    print J <<'LIZENZ';
/* «•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»

    Copyright © 2011, Ingo Wechsung
    All rights reserved.

    Redistribution and use in source and binary forms, with or
    without modification, are permitted provided that the following
    conditions are met:

        Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

        Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution. Neither the name of the copyright holder
        nor the names of its contributors may be used to endorse or
        promote products derived from this software without specific
        prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE
    COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
    PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
    USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
    IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
    THE POSSIBILITY OF SUCH DAMAGE.

    «•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•»«•» */

LIZENZ

    print J "package frege.rt;\r\n";
    print J <<'TEXT';
// $Author$
// $Date$
// $Rev$
// $Id$
TEXT
    print J <<"TEXT";
/**
 * <p> Frege lambdas with arity $n. </p>
 *
 * <p> See {\@link Lam1} for a general discussion of untyped function values. </p>
 *
 */
public abstract class Lam$n extends Lambda {
   /**
     * <p>Apply this function to an argument.</p>
     *
     * <p> This method creates an instance of {\@link Lam$p} that collects the
     * remaining arguments and, when evaluated, invokes the {\@link Lam$n#eval} method of this
     * class.</p>
     *
     * \@return an instance of type <tt>Lam$p</tt> that waits for the
     * remaining arguments to be supplied and calls back with all arguments.
     */
    final public Lam$p apply(final Lazy<FV> arg1) {
        return new Lam$p () {
            final public Lazy<FV> eval($crpargs) {
                return Lam$n.this.eval($crargs);
            }
        };
    }
    /**
     * <p>Apply this function to all its arguments at once.</p>
     *
     * <p> This method creates an instance of {\@link Unknown} that,
     * when evaluated, invokes the {\@link Lam$n#eval} method of this
     * function.</p>
     *
     * Use of this method is preferrable if all arguments are known compared
     * to repeated invokation of the single argument form since intermediate
     * closure creation is saved.
     *
     * \@return an instance of type <tt>Unknown&lt;FV&gt;</tt>
     */
    final public Unknown<FV> apply($cnargs) {
        return new Unknown<FV> () {
            final public Lazy<FV> _v() { return Lam$n.this.eval($crargs); }
        };
    }
    
    /**
     * <p> Run the function. </p>
     *
     * <p> The run method will be called by the {\@link Lam$p#eval} method
     * of the lambda object resulting from <tt>this.apply(...)</tt>.
     * It actually performs computation and
     * returns a result or another lazy value that will evaluate to the result.<br>
     * This method must be implemented by all subclasses.</p>
     *
     * <p>
     * Note that the arguments must be passed in reverse order. The reason is that
     * in this way the byte code for any intermediate closure will only have to
     * push its argument and invoke the next higher closure's <tt>eval</tt> method.
     * A reordering of the arguments on the stack will not be needed. This could save
     * a substantial amounts of memory writes (I hope).
     * </p>
     *
     *
     * \@return boxed and possibly lazy result
     */
    abstract public Lazy<FV> eval($crpargs, Lazy<FV> arg1);
}
TEXT
    # print "joined=", (join (",", @targs)), "\n";
    close J;
    $n++;
}