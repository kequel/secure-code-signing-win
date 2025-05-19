using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MKA_Demo_App
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();

            Button btn = new Button();
            btn.Text = "Click.";
            btn.Click += (sender, e) => MessageBox.Show("You clicked the button. ");
            btn.Dock = DockStyle.Fill;
            this.Controls.Add(btn);
        }
    }
}
