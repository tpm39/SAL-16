
// The SAL-16 Conditional Jump Decoder

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class JumpDecoder extends InstanceFactory {
    JumpDecoder() {
        super("Jump Decoder");

        setAttributes(
                new Attribute[] { StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-100, -80, 100, 160));

        setPorts(new Port[] {
                new Port(-100, -50, Port.INPUT, 1), // c
                new Port(-100, -30, Port.INPUT, 1), // a
                new Port(-100, -10, Port.INPUT, 1), // e
                new Port(-100, 10, Port.INPUT, 1),  // z
                new Port(-100, 30, Port.INPUT, 1),  // n
                new Port(-100, 50, Port.INPUT, 1),  // v
                new Port(-80, 80, Port.INPUT, 1),   // c3
                new Port(-60, 80, Port.INPUT, 1),   // c2
                new Port(-40, 80, Port.INPUT, 1),   // c1
                new Port(-20, 80, Port.INPUT, 1),   // c0
                new Port(0, 0, Port.OUTPUT, 1)      // jmp
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth() / 2, bds.getY() - 3,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        int c = state.getPortValue(0).toIntValue();
        int a = state.getPortValue(1).toIntValue();
        int e = state.getPortValue(2).toIntValue();
        int z = state.getPortValue(3).toIntValue();
        int n = state.getPortValue(4).toIntValue();
        int v = state.getPortValue(5).toIntValue();

        int c3 = state.getPortValue(6).toIntValue();
        int c2 = state.getPortValue(7).toIntValue();
        int c1 = state.getPortValue(8).toIntValue();
        int c0 = state.getPortValue(9).toIntValue();

        int cmd = (c3 << 3) + (c2 << 2) + (c1 << 1) + c0;
        int jmp = 0;

        switch(cmd) {
            case 0x0:  // JEQ
                if (e == 1) jmp = 1;
                break;
            case 0x1:  // JNE
                if (e == 0) jmp = 1;
                break;
            case 0x2:  // JZ
                if (z == 1) jmp = 1;
                break;
            case 0x3:  // JNZ
                if (z == 0) jmp = 1;
                break;
            case 0x4:  // JC
                if (c == 1) jmp = 1;
                break;
            case 0x5:  // JNC
                if (c == 0) jmp = 1;
                break;
            case 0x6:  // JGT
                if (a == 1) jmp = 1;
                break;
            case 0x7:  // JGE
                if (a == 1 || e == 1) jmp = 1;
                break;
            case 0x8:  // JLT
                if (a == 0 && e == 0) jmp = 1;
                break;
            case 0x9:  // JLE
                if (a == 0 || e == 1) jmp = 1;
                break;
            case 0xa:  // JPL
                if (n == 0 && z == 0) jmp = 1;
                break;
            case 0xb:  // JMI
                if (n == 1 && z == 0) jmp = 1;
                break;
            case 0xc:  // JV
                if (v == 1) jmp = 1;
                break;
            case 0xd:  // JNV
                if (v == 0) jmp = 1;
                break;
            default:
                // Nothing to do
        }

        Value jmpv = Value.createKnown(BitWidth.create(1), jmp);
        state.setPort(10, jmpv, 17);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "Jump Decode");
        painter.drawPort(0, "c", Direction.EAST);
        painter.drawPort(1, "a", Direction.EAST);
        painter.drawPort(2, "e", Direction.EAST);
        painter.drawPort(3, "z", Direction.EAST);
        painter.drawPort(4, "n", Direction.EAST);
        painter.drawPort(5, "v", Direction.EAST);
        painter.drawPort(6, "c3", Direction.SOUTH);
        painter.drawPort(7, "c2", Direction.SOUTH);
        painter.drawPort(8, "c1", Direction.SOUTH);
        painter.drawPort(9, "c0", Direction.SOUTH);
        painter.drawPort(10, "jmp", Direction.WEST);
        painter.drawLabel();
    }
}
