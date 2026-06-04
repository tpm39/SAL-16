
// The SAL-16 Stack Pointer

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class StackPointer extends InstanceFactory {
    private final int STACK_MAX = 0xffef;
    private final Value VAL_0 = Value.createKnown(BitWidth.create(1), 0);
    private final Value VAL_1 = Value.createKnown(BitWidth.create(1), 1);

    StackPointer() {
        super("Stack Pointer");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-100, -30, 100, 120));

        setPorts(new Port[]{
                new Port(-100, 0, Port.INPUT, 1),              // set
                new Port(-100, 20, Port.INPUT, 1),             // read
                new Port(-100, 40, Port.INPUT, 1),             // i_d
                new Port(-100, 60, Port.INPUT, 1),             // set_hp
                new Port(-70, 90, Port.INPUT, StdAttr.WIDTH),  // top_hp
                new Port(-20, 90, Port.INPUT, 1),              // reset
                new Port(0, 0, Port.OUTPUT, StdAttr.WIDTH),    // cont
                new Port(0, 20, Port.OUTPUT, StdAttr.WIDTH),   // sp
                new Port(0, 40, Port.OUTPUT, 1)                // err
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth() / 2, bds.getY() - 3,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        int set = state.getPortValue(0).toIntValue();
        int read = state.getPortValue(1).toIntValue();
        int i_d = state.getPortValue(2).toIntValue();
        int set_hp = state.getPortValue(3).toIntValue();
        int top_hp = state.getPortValue(4).toIntValue();
        int reset = state.getPortValue(5).toIntValue();

        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);
        StackPointerData data = StackPointerData.get(state, nBits);

        // Update "cont" or the top of the heap
        int val;
        if (reset == 1) {
            data.reset(nBits);
        }
        else if ((set == 1) && (set_hp == 0)) {
            if (i_d == 0)
                val = data.getPtr().toIntValue() + 1;
            else
                val = data.getPtr().toIntValue() - 1;
            data.setPtr(Value.createKnown(nBits, val));
        }
        else if ((set == 1) && (set_hp == 1)) {
            data.setTopHeap(Value.createKnown(nBits, top_hp));
        }
        state.setPort(6, data.getPtr(), 17);

        // Enable/Disable "sp"
        Value spv;
        if (read == 1) {
            spv = data.getPtr();
        }
        else {
            spv = Value.createUnknown(nBits);
        }
        state.setPort(7, spv, 17);

        // Check for stack violation
        val = data.getPtr().toIntValue();
        Value errv = VAL_0;
        int th = data.getTopHeap().toIntValue();
        if ((val > STACK_MAX) || (val == th))
            errv = VAL_1;
        state.setPort(8, errv, 2);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "Stack Ptr");
        painter.drawPort(0, "set", Direction.EAST);
        painter.drawPort(1, "read", Direction.EAST);
        painter.drawPort(2, "i_d", Direction.EAST);
        painter.drawPort(3, "set_hp", Direction.EAST);
        painter.drawPort(4, "top_hp", Direction.SOUTH);
        painter.drawPort(5, "reset", Direction.SOUTH);
        painter.drawPort(6, "cont", Direction.WEST);
        painter.drawPort(7, "sp", Direction.WEST);
        painter.drawPort(8, "err", Direction.WEST);
        painter.drawLabel();
    }
}

