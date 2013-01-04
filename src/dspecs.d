import core.exception: AssertError;
import std.stdio:      writeln;

private string currentSubject;

auto should(string subject) @property
{
    static struct Should
    {
        string subject;

        void opBinary(string op)(void delegate() content)
        {
            currentSubject = subject;
            content();
            currentSubject = "";
        }
    }

    return Should(subject);
}

alias ha = should;
alias は = should;

auto by(string test) @property
{
    static struct By
    {
        string test;

        void opBinary(string op, string file = __FILE__, int line = __LINE__)(void delegate() content)
        {
            bool error;
            try
            {
                content();
            }
            catch(AssertError Unused)
            {
                error = true;
            }
            finally
            {
                writeln(file, "(", line, "): Test ",  error ? "failure" : "success", ": ", currentSubject.length ? currentSubject ~ " should " ~ test : test);
            }
        }
    }

    return By(test);
}

auto beki(string test) @property
{
    static struct Beki
    {
        string test;

        void opBinary(string op, string file = __FILE__, int line = __LINE__)(void delegate() content)
        {
            bool error;
            try
            {
                content();
            }
            catch(AssertError Unused)
            {
                error = true;
            }
            finally
            {
                writeln(file, "(", line, "): Test ",  error ? "failure" : "success", ": ", currentSubject.length ? currentSubject ~ "は、" ~ test : test, "べきだ");
            }
        }
    }

    return Beki(test);
}

alias べき = beki;

version(unittest)
{
    import std.algorithm: startsWith, endsWith;

    struct Hoge
    {
        bool match = true;
        string str = "abc";
    }

    struct Piyo
    {
        int i;
        this(int i)
        {
            this.i = i * i;
        }
    }
}

debug(dspecs) unittest
{
    `"abc"`.should |
    {
        `start with "a"`.by |
        {
            assert("abc".startsWith("a"));
        };

        `end with "c"`.by |
        {
            assert("abc".endsWith("c"));
        };
    };

    "initial instance of Hoge".should |
    {
        Hoge hoge;

        "match".by |
        {
            assert(hoge.match);
        };

        `have member str which is "abc"`.by |
        {
            assert(hoge.str == "abc");
        };
    };

    "Piyo(10).iは100である".べき |
    {
        assert(Piyo(10).i == 100);
    };
}
