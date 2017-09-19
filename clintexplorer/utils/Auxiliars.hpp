#ifndef __AUXILIARS__
#define __AUXILIARS__

#include <string>
#include <map>
#include <iostream>

#define DASH '-'

class Auxiliars
{
public:  
  /**
    SplitArgs:
      case -type value: map[-type]=value,
      case -type: map[-type]="",
      case value: map[value]=""
  */
  static std::map<std::string, std::string> splitArgs( int argc, char *argv[] )
  {
    std::map<std::string, std::string> args;
    int count = 1; //skip program name
    while ( count < argc )
    {
      if ( argv[count][0] == DASH )
      {
        //Type
        if ( count + 1 < argc )
        {
          //Maybe pair arguments
          if ( argv[count + 1][0] == DASH )
          {
            //Single argument
            args[argv[count]] = std::string( );
            count+=1;
          }
          else
          {
            //Pair arguments
            args[argv[count]] = argv[count + 1];
            count+=2;
          }
        }
        else
        {
          //Single argument
          args[argv[count]] = std::string( );
          count+=1;
        }
      }
      else
      {
        //Single argument without dash
        args[argv[count]] = std::string( );
        count+=1;
      }
    }
    return args;
  }
};
#endif /* __AUXILIARS__ */
