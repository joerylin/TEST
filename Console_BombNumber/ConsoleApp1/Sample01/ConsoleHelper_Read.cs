using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1.Sample01
{


	public partial class ConsoleHelper
	{
		private String _firstName;
		private String _lastName;
		protected String _Name;
		public String _NickName;

		public String FullName
		{	
			get
			{
				return $"{this._lastName}-{this._firstName}";
			}
		}

		public ConsoleHelper()
		{
		}
		public ConsoleHelper(string name)
		{
		}

		public Boolean IsValid_ReadEnter(String _input, Int32 num_s, Int32 num_e, out Int32 num)
		{
			Boolean flag = false;
			if (Int32.TryParse(_input, out num))
			{
				if (num >= num_s && num <= num_e)
					flag = true;
			}
			return flag;
		}

		public Int32 ReadToInt32(String _input)
		{
			return Int32.Parse(_input);
		}
	}
}
