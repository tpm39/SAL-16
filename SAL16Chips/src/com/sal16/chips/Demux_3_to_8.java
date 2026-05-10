
// The SAL-16 Decoder

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class Demux_3_to_8 extends InstanceFactory {
    Demux_3_to_8() {
        super("Demux 3-8");

        setAttributes(
                new Attribute[] { StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-90, -50, 90, 80));

        setPorts(new Port[] {
                new Port(-90, -20, Port.INPUT, 1),  // A
                new Port(-90, 0, Port.INPUT, 1),    // B
                new Port(-90, 20, Port.INPUT, 1),   // C
                new Port(0, 0, Port.OUTPUT, 8),     // Out
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
        int C = state.getPortValue(2).toIntValue();

        int val = (A << 2) + (B << 1) + C;
        int out = 1 << val;

        Value outv = Value.createKnown(BitWidth.create(8), out);
        state.setPort(3, outv, 17);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "Demux 3-8");
        painter.drawPort(0, "A", Direction.EAST);
        painter.drawPort(1, "B", Direction.EAST);
        painter.drawPort(2, "C", Direction.EAST);
        painter.drawPort(3, "Out", Direction.WEST);
        painter.drawLabel();
    }
}
