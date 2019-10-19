module korwin_bot.utils;

// source: https://www.youtube.com/watch?v=yMNMV9JlkcQ
class Singleton(T)
{
private:
    this() {}

    static bool instantiated_;
    __gshared T instance_;

public:
    static T getInstance()
    {
        if (!instantiated_)
        {
            synchronized (T.classinfo)
            {
                if (!instance_)
                {
                    instance_ = new T();
                }
                instantiated_ = true;
            }
        }
        return instance_;
    }
}
