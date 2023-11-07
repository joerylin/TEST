using System;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLibrary
{
    public class ConsoleWrite
    {

        public static void ConsoleWriteError(String _errMsg)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine(_errMsg);
            Console.ResetColor();
        }

        public static void ConsoleWriteInfo(String _errMsg)
        {
            Console.ForegroundColor = ConsoleColor.Blue;
            Console.WriteLine(_errMsg);
            Console.ResetColor();
        }

        public static void ConsoleWriteTip(String _errMsg)
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine(_errMsg);
            Console.ResetColor();
        }
    }
}
