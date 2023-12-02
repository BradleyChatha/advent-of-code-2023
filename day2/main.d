void main()
{
    import std.file : readText;
    const input = readText("../day2/input.txt");
    part1(input);
    part2(input);
}

struct Round
{
    int red;
    int green;
    int blue;
}

Round[] parseGame(string input)
{
    import std.array     : array;
    import std.algorithm : map, splitter, canFind;
    import std.conv      : to;
    import std.range     : dropOne;

    auto valuesRaw = input.splitter(": ").dropOne.front;
    auto roundsRaw = valuesRaw.splitter("; ");

    return roundsRaw.map!((raw){
        Round round;

        foreach(value; raw.splitter(", "))
        {
            if(value.canFind("red"))
                round.red = value.splitter(" ").front.to!int;
            else if(value.canFind("green"))
                round.green = value.splitter(" ").front.to!int;
            else if(value.canFind("blue"))
                round.blue = value.splitter(" ").front.to!int;
        }

        return round;
    }).array;
}

void part1(string input)
{
    import std.algorithm : map, filter, sum, all;
    import std.range     : enumerate, walkLength, enumerate, tee;
    import std.string    : lineSplitter;
    import std.stdio     : writeln;

    const MAX_RED   = 12;
    const MAX_GREEN = 13;
    const MAX_BLUE  = 14;

    input
        .lineSplitter
        .map!parseGame
        .enumerate
        .map!((tup) => 
            tup.value.all!(r => r.red <= MAX_RED && r.green <= MAX_GREEN && r.blue <= MAX_BLUE)
            ? tup.index+1 : 0
        )
        .sum
        .writeln;
}

void part2(string input)
{
    import std.algorithm : map, filter, sum, all, maxElement;
    import std.range     : enumerate, walkLength, tee;
    import std.string    : lineSplitter;
    import std.stdio     : writeln;

    input
        .lineSplitter
        .map!parseGame
        .map!(rounds =>
            rounds.map!(r => r.red).maxElement
            * rounds.map!(r => r.green).maxElement
            * rounds.map!(r => r.blue).maxElement
        )
        .sum
        .writeln;
}