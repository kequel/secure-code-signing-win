using System;
using System.Windows.Forms;

namespace MKA_Demo_App
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1()); // Upewnij się, że przestrzeń nazw się zgadza
        }
    }
}