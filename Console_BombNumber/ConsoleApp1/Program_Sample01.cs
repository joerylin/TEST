// See https://aka.ms/new-console-template for more information
using CommonLibrary;
using System;
using System.ComponentModel;
using System.Numerics;
using System.Reflection.Metadata.Ecma335;
using System.Runtime.Intrinsics.X86;
using static System.Formats.Asn1.AsnWriter;

namespace ConsoleApp2
{
    class Program_Sample01
    {
        //宣告變數
        static String[] players = new String[2];

        static Int32 numberBomb;

        static void Main(string[] args)
        {
            //公告遊戲規則
            ConsoleWrite.ConsoleWriteInfo("Hello, welcome to play Bomb Of Number game.\r\nThere are numbers from 1, 2, 3, 4.... to 100, and randomise a bomb number N Between 1 and 100.\r\nFor example, if the bomb number is 59,\r\nWhen the player enter 59, then he will lose the game.");

            Console.WriteLine("Please enter player 1's name :");
            players[0] = Console.ReadLine();
            Console.WriteLine("Please enter player 2's name :");
            players[1] = Console.ReadLine();
            //紀錄本次Player名字並歡迎參加!!!
            Console.WriteLine("\r\nWelcome to the game!\r\nPlayer 1:{0}\r\nPlayer 2:{1}", players[0], players[1]);
            ConsoleWrite.ConsoleWriteTip("\r\nIf you would like to know the bomb number, please enter B.\r\nIf you would like to Exit, please enter E.");

            Int16 flag = 0;
            Int32 num_s = 1, num_e = 100, num = -1;
            String readline = String.Empty;
            //Randomly pick the Bomb Number
            numberBomb = GetRandomizeNumber(num_s, num_e);

            while (flag >= 0)
            {
                Console.WriteLine($"Hi {players[flag % 2]},  Please Enter a number between {num_s} and {num_e}：>");
                readline = Console.ReadLine().ToUpper();
                switch (readline)
                {
                    case "B":
                        ConsoleWrite.ConsoleWriteTip($"Borm number = {numberBomb}");
                        break;
                    case "E":
                        ConsoleWrite.ConsoleWriteInfo("Bye~！");
                        flag = -999;
                        break;

                    default:
                        if (IsValid_ReadEnter(readline, num_s, num_e, out num))
                        {
                            if (num == numberBomb)
                            {
                                ConsoleWrite.ConsoleWriteError($"Bomb!!! , {players[flag % 2]} you are failure!!! ");
                                flag = -999;
                            }
                            else if (num > numberBomb)
                                num_e = num - 1;
                            else if (num < numberBomb)
                                num_s = num + 1;
                            flag++;
                        }
                        break;
                }
            }

        }


        /// <summary>
        /// 產生隨機亂數
        /// </summary>
        /// <param name="num_s">起始值</param>
        /// <param name="num_e">最大值</param>
        /// <returns></returns>
        static private Int32 GetRandomizeNumber(Int32 num_s, Int32 num_e)
        {
            Random rng = new Random();
            return rng.Next(num_s, num_e);
        }

        static private Boolean IsValid_ReadEnter(String _input, Int32 num_s, Int32 num_e, out Int32 num)
        {
            Boolean flag = false;
            if (Int32.TryParse(_input, out num))
            {
                if (num >= num_s && num <= num_e)
                    flag = true;
                //else                        //因預設為False，故此處可省略
                //flag = false;
            }
            //else     
            //flag = false;
            return flag;
        }


    }
}
