
// The SAL-16 Maths Unit

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class MathsUnit extends InstanceFactory {
    MathsUnit() {
        super("Maths Unit");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-50, -60, 140, 60));

        setPorts(new Port[] {
                new Port(-50, -40, Port.INPUT, StdAttr.WIDTH),  // A
                new Port(-50, -20, Port.INPUT, StdAttr.WIDTH),  // B
                new Port(-20, 0, Port.INPUT, 3),           // op
                new Port(0, 0, Port.OUTPUT, 1),            // v
                new Port(20, 0, Port.OUTPUT, 1),           // n
                new Port(40, 0, Port.OUTPUT, 1),           // z
                new Port(60, 0, Port.OUTPUT, 1),           // co
                new Port(90, -30, Port.OUTPUT, StdAttr.WIDTH)   // C
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth() / 2, bds.getY() - 3,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        int A = state.getPortValue(0).toIntValue();
        int B = state.getPortValue(1).toIntValue();
        int op = state.getPortValue(2).toIntValue();

        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);
        int max = (int)Math.pow(2, nBits.getWidth());
        int nMask = 1 << (nBits.getWidth() - 1);

        double dA, dB, dC;

        int C, v, n, z, co;
        C = v = n = z = co = 0;

        boolean aPos, bPos, cPos;

        switch(op) {
            case 0x0:  // Subtract
                C = A - B;

                // Adjust result if required
                if (C < 0) {
                    C += max;
                    co = 1;
                }

                // Test for overflow
                aPos = A < max/2;
                bPos = B < max/2;
                cPos = C < max/2;
                if (aPos && !bPos && !cPos)
                    v = 1;
                else if (!aPos && bPos && cPos)
                    v = 1;
                break;

            case 0x1:  // Multiply
                // Check for a carry being generated
                C = A * B;
                if (C >= max) co = 1;

                // Adjust operands if required (SAL-16 uses a signed multiplier)
                if (A >= max/2) A -= max;
                if (B >= max/2) B -= max;

                C = A * B;

                // Adjust result if required
                if ((C >= max/2) || (C < -max/2)) {
                    C &= (max - 1);
                    v = 1;
                }
                break;

            case 0x2:  // Signed Division
                // Dunno why: But the 'Maths Unit' wasn't working in SAL-16
                // when using integer division - So now using floats ...

                // Adjust operands if required
                if (A >= max/2) A -= max;
                if (B >= max/2) B -= max;

                // Logisim Divider just returns A on division by 0
                if (B == 0) B = 1;

                // Do the division
                dA = (double)A;
                dB = (double)B;
                dC = dA / dB;
                if (dC < 0) dC = Math.ceil(dC);
                else dC = Math.floor(dC);
                C = (int)dC;

                // Adjust result if required
                if (C < 0) C += max;
                break;

            case 0x3:  // Unsigned Division
                // Dunno why: But the 'Maths Unit' wasn't working in SAL-16
                // when using integer modulus - So now using floats ...

                // Logisim Divider just returns A on division by 0
                if (B == 0) B = 1;

                dA = (double)A;
                dB = (double)B;
                dC = dA / dB;
                C = (int)dC;
                break;

            default:
                // Invalid ...
        }

        if (C == 0) z = 1;

        if ((C & nMask) == nMask) n = 1;

        Value vv = Value.createKnown(BitWidth.create(1), v);
        state.setPort(3, vv, 17);
        Value nv = Value.createKnown(BitWidth.create(1), n);
        state.setPort(4, nv, 17);
        Value zv = Value.createKnown(BitWidth.create(1), z);
        state.setPort(5, zv, 17);
        Value cov = Value.createKnown(BitWidth.create(1), co);
        state.setPort(6, cov, 17);
        Value Cv = Value.createKnown(nBits, C);
        state.setPort(7, Cv, 17);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "Maths");
        painter.drawPort(0, "A", Direction.EAST);
        painter.drawPort(1, "B", Direction.EAST);
        painter.drawPort(2, "op", Direction.SOUTH);
        painter.drawPort(3, "V", Direction.SOUTH);
        painter.drawPort(4, "N", Direction.SOUTH);
        painter.drawPort(5, "Z", Direction.SOUTH);
        painter.drawPort(6, "Co", Direction.SOUTH);
        painter.drawPort(7, "C", Direction.WEST);
        painter.drawLabel();
    }
}

