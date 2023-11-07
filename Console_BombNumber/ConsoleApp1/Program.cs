// See https://aka.ms/new-console-template for more information
using System;
using System.ComponentModel;
using System.Numerics;
using System.Reflection.Metadata.Ecma335;
using System.Runtime.Intrinsics.X86;
using static System.Formats.Asn1.AsnWriter;

namespace ConsoleApp2
{
    class Lab1
    {
        static void Main(string[] args)

        {
            //公告遊戲規則
            Console.WriteLine("Hello, welcome to play Bomb Of Number game.\r\nThere are numbers from 0,1, 2, 3, 4.... to 100, and randomise a bomb number N Between 1 and 100.\r\nFor example, if the bomb number is 59,\r\nWhen the player enter 59, then he will lose the game.");

            //紀錄本次Player名字並歡迎參加!!!
            String player1;
            String player2;
            Console.WriteLine("Please enter player1's name :");
            player1 = Console.ReadLine();
            Console.WriteLine("Please enter player2's name :");
            player2 = Console.ReadLine();

            Console.WriteLine("\r\nWelcome to the game!\r\nPlayer 1:{0}\r\nPlayer 2:{1}", player1, player2);
            Console.WriteLine("\r\nIf you would like to know the bomb number and give up the game, please enter B.\r\nIf you would like to Exit, please enter E.");

            //Randomly pick the Bomb Number
            Random rng = new Random();
            int x = rng.Next(100);

            //判別此輪是Player1 or Player2 ?
            String playerCurrent;
            int flag = 1;
            int begin = 0;
            int end = 100;
            int bOut_Ind = 0;

            if (flag >= 0)
            {
                playerCurrent = player1;
                Console.WriteLine("\r\n{0},Please enter a number between {1} and {2}.", playerCurrent, begin, end);
                flag++;
                int n;

                while (true)
                {
                    String takeoff = Console.ReadLine();
                    switch (takeoff)
                    {
                        case "B":
                            Console.WriteLine(x);
                            flag = -1;
                            break;
                        case "E":
                            flag = -1;
                            break;
                        default:
                            bool result = int.TryParse(takeoff, out n);
                            if (result)
                            {
                                int guess = int.Parse(takeoff);
                                if (guess > end || guess < begin)
                                {
                                    Console.WriteLine("Out of range. Try again!");
                                    //takeoff = Console.ReadLine(); 入口
                                    continue;
                                }
                                else
                                {
                                    if (guess == x)
                                    {
                                        Console.WriteLine("Bomb !!!\r\n{0},You lost the game.", playerCurrent);
                                        break;
                                    }
                                    else if (guess > x)
                                    {
                                        end = guess - 1;
                                        Console.WriteLine("({0},{1})", begin, end);
                                    }
                                    else if (guess < x)
                                    {
                                        begin = guess + 1;
                                        Console.WriteLine("({0},{1})", begin, end);
                                    }
                                }

                                if (begin == end)
                                {
                                    Console.WriteLine("Game Over!");
                                    break;
                                }
                            }
                            else
                            {
                                Console.WriteLine("It's not a number. Try again!");
                                takeoff = Console.ReadLine();
                                continue;
                            }
                            if (flag % 2 == 0)
                            {
                                playerCurrent = player2;
                            }
                            else
                            {
                                playerCurrent = player1;
                            }
                            Console.WriteLine("{0},Please enter a number between {1} and {2}.", playerCurrent, begin, end);
                            flag++;
                            //takeoff = Console.ReadLine(); 入口
                            continue;
                            //break;                       
                    }
                    break;
                }
                Console.WriteLine("Bye! Bye!");
                flag = -1;
            }
        }
    }
}
