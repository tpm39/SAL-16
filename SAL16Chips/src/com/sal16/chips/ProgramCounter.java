
// The SAL-16 Program Counter

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class ProgramCounter extends InstanceFactory {
    ProgramCounter() {
        super("Program Counter");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-110, -30, 110, 100));

        setPorts(new Port[]{
                new Port(-110, 0, Port.INPUT, StdAttr.WIDTH),   // Din
                new Port(-110, 20, Port.INPUT, 1),         // W
                new Port(-110, 40, Port.INPUT, 1),         // save
                new Port(-80, 70, Port.INPUT, 1),          // Reset
                new Port(-30, 70, Port.OUTPUT, StdAttr.WIDTH),  // Cont
                new Port(0, 0, Port.OUTPUT, StdAttr.WIDTH),     // Dout
                new Port(0, 20, Port.INPUT, 1),            // R
                new Port(0, 40, Port.INPUT, 1)             // restr
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth() / 2, bds.getY() - 3,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        int R = state.getPortValue(6).toIntValue();
        int W = state.getPortValue(1).toIntValue();
        int restr = state.getPortValue(7).toIntValue();
        int save = state.getPortValue(2).toIntValue();
        int Reset = state.getPortValue(3).toIntValue();

        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);
        ProgramCounterData data = ProgramCounterData.get(state, nBits);

        // Update "cont" & "saved"
        if (Reset == 1) {
            data.reset(nBits);
        }
        else if (W == 1) {
            data.setConts(state.getPortValue(0));
        }
        else if (save == 1) {
            data.setSaved(data.getConts());
        }
        else if (restr == 1) {
            data.setConts(data.getSaved());
        }
        state.setPort(4, data.getConts(), 17);

        // Enable/Disable "Dout"
        Value Doutv;
        if (R == 1) {
            Doutv = data.getConts();
        }
        else {
            Doutv = Value.createUnknown(nBits);
        }
        state.setPort(5, Doutv, 17);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "PC");
        painter.drawPort(0, "Din", Direction.EAST);
        painter.drawPort(1, "W", Direction.EAST);
        painter.drawPort(2, "save", Direction.EAST);
        painter.drawPort(3, "Reset", Direction.SOUTH);
        painter.drawPort(4, "Cont", Direction.SOUTH);
        painter.drawPort(5, "Dout", Direction.WEST);
        painter.drawPort(6, "R", Direction.WEST);
        painter.drawPort(7, "restr", Direction.WEST);
        painter.drawLabel();
    }
}

