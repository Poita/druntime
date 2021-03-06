/**
 * The goal of this program is to do very CPU intensive work in threads
 *
 * Copyright: Copyright Leandro Lucarella 2014.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Leandro Lucarella
 */
// EXECUTE_ARGS: 50 4 extra-files/dante.txt

import core.thread;
import core.atomic;
import std.conv;
import std.file;
import std.digest.sha;

auto N = 100;
auto NT = 2;

__gshared ubyte[] BYTES;
shared(int) running; // Atomic

void main(char[][] args)
{
    auto fname = args[0];
    if (args.length > 3)
        fname = args[3];
    if (args.length > 2)
        NT = to!(int)(args[2]);
    if (args.length > 1)
        N = to!(int)(args[1]);
    N /= NT;

    atomicStore(running, NT);
    BYTES = cast(ubyte[]) std.file.read(fname);
    auto threads = new Thread[NT];
    foreach(ref thread; threads)
    {
        thread = new Thread(&doSha);
        thread.start();
    }
    while (atomicLoad(running))
    {
        auto a = new void[](BYTES.length);
        a[] = cast(void[]) BYTES[];
        Thread.yield();
    }
    foreach(thread; threads)
        thread.join();
}

void doSha()
{
    auto sha = new SHA1; // undefined identifier SHA512?
    for (size_t i = 0; i < N; i++)
    {
        sha.put(BYTES);
    }
    running += -1;
}

