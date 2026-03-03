
// The SAL-16 'Set To One' unit

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class SetToOne extends InstanceFactory {
    SetToOne() {
        super("Set To One");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-10, -40, 90, 40));

        setPorts(new Port[] {
                new Port(0, -40, Port.INPUT, StdAttr.WIDTH),  // A
                new Port(80, -20, Port.INPUT, 1),        // S
                new Port(0, 0, Port.OUTPUT, StdAttr.WIDTH)    // B
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth() / 2, bds.getY() - 3,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        int s = state.getPortValue(1).toIntValue();
        Value bv;

        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);

        if (s == 1) {
            bv = Value.createKnown(nBits, 1);
        }
        else {
            bv = Value.createKnown(nBits, state.getPortValue(0).toIntValue());
        }
        state.setPort(2, bv, 2);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "Set 1");
        painter.drawPort(0, "A", Direction.NORTH);
        painter.drawPort(1, "S", Direction.WEST);
        painter.drawPort(2, "B", Direction.SOUTH);
        painter.drawLabel();
    }
}
