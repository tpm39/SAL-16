
// The SAL-16 FPU Unit

// NB: This only deals with 16 bit numbers

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class FPU extends InstanceFactory {
    FPU() {
        super("FPU");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-90, -70, 120, 70));

        setPorts(new Port[] {
                // NB: The clear/clk/en inputs are 'redundant' here & the done output is always true.
                new Port(-90, -50, Port.INPUT, StdAttr.WIDTH),  // X
                new Port(-90, -30, Port.INPUT, StdAttr.WIDTH),  // Y
                new Port(-60, 0, Port.INPUT, 1),           // clear
                new Port(-40, 0, Port.INPUT, 1),           // clk
                new Port(-20, 0, Port.INPUT, 1),           // en
                new Port(0, 0, Port.INPUT, 3),             // op
                new Port(30, -30, Port.OUTPUT, 1),         // done
                new Port(30, -50, Port.OUTPUT, StdAttr.WIDTH)   // Z
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth() / 2, bds.getY() - 3,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    private int to_fp_fmt(double val)
    {
        if (Double.isNaN(val)) return 0x7e00;
        else if (val == Double.POSITIVE_INFINITY) return 0x7c00;
        else if (val == Double.NEGATIVE_INFINITY) return 0xfc00;
        else if (val == 0.0) return 0x0000;

        int sign = 0;
        int exp = 0;
        int mant = 0;

        if (val < 0.0)  {
            sign = 1;
            val *= -1;
        }

        // Get the exponent
        exp = 15;

        // If the number's 2 or above keep dividing by 2 until it's not.
        // While doing this the exponent must be incremented for each division,
        // so that val * 2^exp remains equal to the initial number.
        while (val >= 2.0) {
            val /= 2.0;
            exp += 1;
        }

        // Numbers beyond the normal range are infinite
        if (exp > 30) {
            if (sign == 0) return 0x7c00;
            else return 0xfc00;
        }

        // If the number's below 1 keep multiplying by 2 until it's not.
        // While doing this the exponent must be decremented for each multiplication,
        // so that val * 2^exp remains equal to the initial number.
        while (val < 1.0) {
            val *= 2.0;
            exp -= 1;
            if (exp == 0) {
                // It's a subnormal number - exponent can't be lowered further
                val /= 2.0;
                break;
            }
        }

        // Get the mantissa

        // Get rid of the leading '1' for normal numbers
        if (exp != 0) val -= 1.0;

        for (int i = 0; i < 10; i++) {
            val = 2 * val;
            mant = (mant << 1);
            if (val >= 1.0) {
                val -= 1.0;
                mant += 1;
            }
        }

        // Perform any rounding if necessary
        for (int i = 10; i < 21; i++) {
            val = 2 * val;
            if (val >= 1.0) {
                mant += 1;
                break;
            }
        }

        int fp_fmt = (sign << 15) + (exp << 10) + mant;
        return fp_fmt;
    }

    private double to_double(int val) {
        double valdbl;

        // Extract the sign bit, exponent & mantissa
        int sign = (val & 0x8000) >> 15;
        int exp = (val & 0x7c00) >> 10;
        int mant = (val & 0x03ff);

        // Convert the mantissa to its floating point value
        double mant_val = mant / Math.pow(2,10);

        // Deal with Subnormal numbers & zero
        if (exp == 0) {
            if (mant == 0) {
                // Zero
                return 0.0;
            }
            else {
                // Subnormal
                valdbl = (Math.pow(2,-14) *  mant_val);
            }
        }

        // Deal with numbers beyond the Normal/Subnormal limits
        else if (exp == 0x1f) {
            if (mant == 0) {
                // +/- Infinity
                if (sign == 0) return Double.POSITIVE_INFINITY;
                else return Double.NEGATIVE_INFINITY;
            }
            else {
                // NaN
                return Double.NaN;
            }
        }

        // Deal with normal numbers
        else {
            valdbl = (Math.pow(2,(exp - 15)) * (1 + mant_val));
        }

        if (sign == 1) valdbl *= -1;

        return valdbl;
    }

    public void propagate(InstanceState state) {
        int Xfp = state.getPortValue(0).toIntValue();
        int Yfp = state.getPortValue(1).toIntValue();
        int op = state.getPortValue(5).toIntValue();

        int Zfp;
        int done = 1;

        double X = to_double(Xfp);
        double Y = to_double(Yfp);
        double Z = 0.0;

        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);

        switch(op) {
            case 0x0:  // Add
                Z = X + Y;
                break;

            case 0x1:  // Subtract
                Z = X - Y;
                break;

            case 0x2:  // Multiply
                Z = X * Y;
                break;

            case 0x3:  // Divide
                Z = X / Y;
                break;

            case 0x4:  // Square Root
                Z = Math.sqrt(X);
                break;

            case 0x5:  // Sin
                Z = Math.sin(Math.toRadians(X));
                break;

            case 0x6:  // Cos
                Z = Math.cos(Math.toRadians(X));
                break;

            case 0x7:  // Tan
                Z = Math.tan(Math.toRadians(X));
                break;

            default:
                // Nothing to do
        }

        Zfp = to_fp_fmt(Z);

        Value donev = Value.createKnown(BitWidth.create(1), done);
        state.setPort(6, donev, 17);
        Value Zv = Value.createKnown(nBits, Zfp);
        state.setPort(7, Zv, 17);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "FPU");
        painter.drawPort(0, "X", Direction.EAST);
        painter.drawPort(1, "Y", Direction.EAST);
        painter.drawPort(2, "clr", Direction.SOUTH);
        painter.drawPort(3, "clk", Direction.SOUTH);
        painter.drawPort(4, "en", Direction.SOUTH);
        painter.drawPort(5, "op", Direction.SOUTH);
        painter.drawPort(6, "done", Direction.WEST);
        painter.drawPort(7, "Z", Direction.WEST);
        painter.drawLabel();
    }
}

