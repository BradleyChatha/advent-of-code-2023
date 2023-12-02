
void main()
{
    import std.file : readText;
    const input = readText("../day1/input.txt");
    part1(input);
    part2(input);
}

void part1(string input)
{
    import std.algorithm : map, sum;
    import std.conv      : to;
    import std.range     : retro;
    import std.string    : lineSplitter, indexOfAny, lastIndexOfAny;
    import std.stdio     : writeln;

    immutable DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    input
        .lineSplitter
        .map!((line) {
            char[2] number;
            number[0] = line[line.indexOfAny(DIGITS)];
            number[1] = line[line.lastIndexOfAny(DIGITS)];
            return number.dup;
        })
        .map!(to!int)
        .sum
        .writeln;
}

void part2(string input)
{
    import std.array     : Appender;
    import std.algorithm : map, sum, each;
    import std.conv      : to;
    import std.exception : assumeUnique;
    import std.range     : retro;
    import std.regex     : regex, matchAll;
    import std.string    : lineSplitter, indexOfAny, lastIndexOfAny;
    import std.stdio     : writeln;

    Appender!(char[]) newInput;
    void transformLine(string line)
    {
        for(ptrdiff_t i = line.length - 1; i >= 0; i--)
        {
            bool lookAhead(string text)
            {
                if(i + text.length > line.length)
                    return false;
                else if(line[i..i+text.length] != text)
                    return false;
                return true;
            }

            switch(line[i])
            {
                case 'o':
                    if(lookAhead("one"))
                        newInput.put('1');
                    else
                        newInput.put(line[i]);
                    break;

                case 't':
                    if(lookAhead("two"))
                        newInput.put('2');
                    else if(lookAhead("three"))
                        newInput.put('3');
                    else
                        newInput.put(line[i]);
                    break;

                case 'f':
                    if(lookAhead("four"))
                        newInput.put('4');
                    else if(lookAhead("five"))
                        newInput.put('5');
                    else
                        newInput.put(line[i]);
                    break;

                case 's':
                    if(lookAhead("six"))
                        newInput.put('6');
                    else if(lookAhead("seven"))
                        newInput.put('7');
                    else
                        newInput.put(line[i]);
                    break;

                case 'e':
                    if(lookAhead("eight"))
                        newInput.put('8');
                    else
                        newInput.put(line[i]);
                    break;

                case 'n':
                    if(lookAhead("nine"))
                        newInput.put('9');
                    else
                        newInput.put(line[i]);
                    break;

                default:
                    newInput.put(line[i]);
                    break;
            }
        }
        newInput.put('\n');
    }
    input
        .lineSplitter
        .each!transformLine;
    input = newInput.data[0..$-1].assumeUnique; // remove trailing newline

    immutable DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    input
        .lineSplitter
        .map!((line) {
            char[2] number;
            number[1] = line[line.indexOfAny(DIGITS)];
            number[0] = line[line.lastIndexOfAny(DIGITS)];
            return number.dup;
        })
        .map!(to!int)
        .sum
        .writeln;
}