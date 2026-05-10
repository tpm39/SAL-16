
// The SAL-16 'FP to Dec' Unit

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class FPScrPos extends InstanceFactory {
    FPScrPos() {
        super("FPScrPos");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-80, -30, 80, 60));

        setPorts(new Port[] {
                new Port(-80, 0, Port.INPUT, StdAttr.WIDTH),   // X
                new Port(-80, 20, Port.INPUT, StdAttr.WIDTH),  // Y
                new Port(0, 0, Port.OUTPUT, StdAttr.WIDTH),    // pos
                new Port(0, 20, Port.OUTPUT, 1)           // on_scr
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth() / 2, bds.getY() - 3,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    private int fp_to_dec(int val) {
        // Values < 0.5 equate to 0
        if (val < 0x3800)
            return 0x0000;

        // Extract the sign bit, exponent & (1 + mantissa)
        int sign = (val & 0x8000) >> 15;
        int exp = (val & 0x7c00) >> 10;
        int mant1 = 0x0400 + (val & 0x03ff);

        int dec = mant1 >> (25 - exp);
        int round = (mant1 << (exp - 14)) & 0x7fff;

        if (round > 0x3ff) {
            // Round up
            dec += 1;
        }

        if (sign == 1) {
            // Multiply by -1
            dec = (~dec + 1) & 0xffff;
        }

        return dec;
    }

    public void propagate(InstanceState state) {
        int Xfp = state.getPortValue(0).toIntValue();
        int Yfp = state.getPortValue(1).toIntValue();

        // Get 'pos' in the correct format for the Graphics Unit
        int xpos = fp_to_dec(Xfp);
        int ypos = fp_to_dec(Yfp);

        xpos += 0x007f;
        ypos = (0x007f - ypos) << 8;
        int pos = xpos + ypos;

        // Is the point within the Graphics Screen bounds ?
        int on_scr = 0;
        Xfp &= 0x7fff;
        Yfp &= 0x7fff;
        if ((Xfp < 0x57f8) && (Yfp < 0x57f8)) on_scr = 1;

        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);

        Value posv = Value.createKnown(nBits, pos);
        state.setPort(2, posv, 17);
        Value onscrv = Value.createKnown(BitWidth.create(1), on_scr);
        state.setPort(3, onscrv, 17);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "FP Scr Pos");
        painter.drawPort(0, "X", Direction.EAST);
        painter.drawPort(1, "Y", Direction.EAST);
        painter.drawPort(2, "pos", Direction.WEST);
        painter.drawPort(3, "on_scr", Direction.WEST);
        painter.drawLabel();
    }
}

