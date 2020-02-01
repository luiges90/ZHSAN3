using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZHSAN3
{
    struct IntPosition
    {
        int x;
        int y;

        public IntPosition(int rx, int ry)
        {
            x = rx;
            y = ry;
        }

        public IntPosition(float rx, float ry)
        {
            x = (int)rx;            
            y = (int)ry;
        }
    }
}
