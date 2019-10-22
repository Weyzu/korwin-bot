module korwin_bot.wisdoms;

import std.conv : to;
import std.stdio;
import std.random;
import std.range;

import korwin_bot.utils;

immutable int MAX_WISDOM_PARTS = 6;

class Wisdoms : Singleton!Wisdoms
{
public:
    void load(const string filePath)
    {
        auto file = File(filePath);
        auto range = file.byLine();
        int wisdomPhrasePart = 0;

        foreach (line; range)
        {
            if (!line.empty && line[0] != '#')
                this.wisdoms[wisdomPhrasePart] ~= to!string(line);
            else if(to!string(line[0]) == "#")
            {
                wisdomPhrasePart++;
                assert(
                    wisdomPhrasePart < MAX_WISDOM_PARTS, 
                    "Wisdoms file contains too many parts"
                );
            }
        }
    }

    @safe
    string generate()
    {
        auto rnd = Random(unpredictableSeed);
        string phrase;

        for (int i = 0; i < MAX_WISDOM_PARTS; i++)
        {
            phrase ~= this.wisdoms[i][uniform(0, this.wisdoms[i].length, rnd)];
        }
        return phrase;
    }

private:
    string[][MAX_WISDOM_PARTS] wisdoms;
}
