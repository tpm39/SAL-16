
// The SAL-16 Register

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class Register extends InstanceFactory {
    Register() {
        super("Register");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-110, -30, 110, 90));

        setPorts(new Port[] {
                new Port(-110, 0, Port.INPUT, StdAttr.WIDTH),   // Din
                new Port(0, 30, Port.INPUT, 1),            // R
                new Port(-110, 30, Port.INPUT, 1),         // W
                new Port(-80, 60, Port.INPUT, 1),          // Reset
                new Port(0, 0, Port.OUTPUT, StdAttr.WIDTH),     // Dout
                new Port(-30, 60, Port.OUTPUT, StdAttr.WIDTH),  // Cont
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth()/2, bds.getY() + bds.getHeight()/2 + 10,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        int r = state.getPortValue(1).toIntValue();
        int w = state.getPortValue(2).toIntValue();
        int reset = state.getPortValue(3).toIntValue();

        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);
        RegisterData data = RegisterData.get(state, nBits);

        if (reset == 1) {
            data.reset(nBits);
        }
        else if (w == 1) {
            data.setVal(state.getPortValue(0));
        }
        state.setPort(5, data.getVal(), 17);

        Value doutv;
        if (r == 1) {
            doutv = data.getVal();
        }
        else {
            doutv = Value.createUnknown(nBits);
        }
        state.setPort(4, doutv, 17);
    }

    public void paintInstance(InstancePainter painter) {
        int nBits = painter.getAttributeValue(StdAttr.WIDTH).getWidth();
        String name = nBits + "-Bit Reg";
        painter.drawRectangle(painter.getBounds(), name);
        painter.drawPort(0, "Din", Direction.EAST);
        painter.drawPort(1, "R", Direction.WEST);
        painter.drawPort(2, "W", Direction.EAST);
        painter.drawPort(3, "Reset", Direction.SOUTH);
        painter.drawPort(4, "Dout", Direction.WEST);
        painter.drawPort(5, "Cont", Direction.SOUTH);
        painter.drawLabel();
    }
}

