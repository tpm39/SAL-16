
// The SAL-16 ALU

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class ALU extends InstanceFactory {
    ALU() {
        super("ALU");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-90, -30, 90, 190));

        setPorts(new Port[]{
                new Port(-90, 0, Port.INPUT, StdAttr.WIDTH),   // A
                new Port(-90, 20, Port.INPUT, StdAttr.WIDTH),  // B
                new Port(-90, 40, Port.INPUT, 1),         // op2
                new Port(-90, 60, Port.INPUT, 1),         // op1
                new Port(-90, 80, Port.INPUT, 1),         // op0
                new Port(-90, 100, Port.INPUT, 1),        // asr
                new Port(-90, 120, Port.INPUT, 1),        // fcmp
                new Port(0, 0, Port.OUTPUT, StdAttr.WIDTH),    // C
                new Port(0, 20, Port.OUTPUT, 1),          // co
                new Port(0, 40, Port.OUTPUT, 1),          // gt
                new Port(0, 60, Port.OUTPUT, 1),          // eq
                new Port(0, 80, Port.OUTPUT, 1),          // z
                new Port(0, 100, Port.OUTPUT, 1),         // n
                new Port(0, 120, Port.OUTPUT, 1),         // v
                new Port(0, 140, Port.INPUT, 1)           // lr_id
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
        int op2 = state.getPortValue(2).toIntValue();
        int op1 = state.getPortValue(3).toIntValue();
        int op0 = state.getPortValue(4).toIntValue();
        int asr = state.getPortValue(5).toIntValue();
        int fcmp = state.getPortValue(6).toIntValue();
        int lr_id = state.getPortValue(14).toIntValue();

        int C, co, gt, eq, z, n, v;
        C = co = gt = eq = z = n = v = 0;

        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);
        int max = (int)Math.pow(2, nBits.getWidth()) - 1;
        int nMask = 1 << (nBits.getWidth() - 1);

        int op = (op2 << 2) + (op1 << 1) + op0;

        switch (op) {
            case 0:  // Addition
                C = A + B;
                if (C > max) {
                    C &= max;
                    co = 1;
                }
                // Test for overflow
                boolean aPos, bPos, cPos;
                aPos = A < 0x8000;
                bPos = B < 0x8000;
                cPos = C < 0x8000;
                if (aPos && bPos && !cPos)
                    v = 1;
                else if (!aPos && !bPos && cPos)
                    v = 1;
                break;
            case 1:  // Shift
                if (B == 0) {  // No shift
                    C = A;
                    break;
                }
                if (lr_id == 0) {  // Left shift
                    C = A << B;
                    co = (C & (max + 1)) >> nBits.getWidth();
                    C &= max;
                }
                else {  // Right shift
                    C = A >> B;  // Do logical shift 1st
                    int mask = 1 << (B - 1);
                    co = (A & mask) >> (B - 1);
                    if (asr == 1) {  // Do any arithmetic shift adjustments
                        if ((A & nMask) == nMask) {
                            mask = 1;
                            for (int i = 0; i < (B-1); i++) {
                                mask = (mask << 1) + 1;
                            }
                            mask = mask << (nBits.getWidth() - B);
                            C |= mask;
                        }
                    }
                }
                break;
            case 2:  // Increment/Decrement
                if (lr_id == 0) {  // Increment
                    C = A + 1;
                    if (C > max) {
                        C = 0;
                        co = 1;
                    }
                }
                else {  // Decrement
                    C = A - 1;
                    if (C < 0) {
                        C = max;
                        co = 1;
                    }
                }
                break;
            case 3:  // NOT
                C = ~A;
                break;
            case 4:  // AND
                C = A & B;
                break;
            case 5:  // OR
                C = A | B;
                break;
            case 6:  // XOR
                C = A ^ B;
                break;
            case 7:  // CMP
                C = 1;
                break;
            default:
                // Nothing to do
        }

        if (A == B) eq = 1;

        boolean Aneg = (A & 0x8000) == 0x8000;

        boolean Bneg = (B & 0x8000) == 0x8000;

        if (Aneg && Bneg) {
            if (fcmp == 1) {
                if (A < B) gt = 1;
            }
            else if (A > B) gt = 1;
        }
        else if (!Aneg) {
            if (Bneg || (A > B)) gt = 1;
        }

        if (C == 0) z = 1;

        if ((C & nMask) == nMask) n = 1;

        Value Cv = Value.createKnown(nBits, C);
        state.setPort(7, Cv, 17);
        Value cov = Value.createKnown(BitWidth.create(1), co);
        state.setPort(8, cov, 17);
        Value gtv = Value.createKnown(BitWidth.create(1), gt);
        state.setPort(9, gtv, 17);
        Value eqv = Value.createKnown(BitWidth.create(1), eq);
        state.setPort(10, eqv, 17);
        Value zv = Value.createKnown(BitWidth.create(1), z);
        state.setPort(11, zv, 17);
        Value nv = Value.createKnown(BitWidth.create(1), n);
        state.setPort(12, nv, 17);
        Value vv = Value.createKnown(BitWidth.create(1), v);
        state.setPort(13, vv, 17);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "ALU");
        painter.drawPort(0, "A", Direction.EAST);
        painter.drawPort(1, "B", Direction.EAST);
        painter.drawPort(2, "Op2", Direction.EAST);
        painter.drawPort(3, "Op1", Direction.EAST);
        painter.drawPort(4, "Op0", Direction.EAST);
        painter.drawPort(5, "asr", Direction.EAST);
        painter.drawPort(6, "fcmp", Direction.EAST);
        painter.drawPort(7, "C", Direction.WEST);
        painter.drawPort(8, "Co", Direction.WEST);
        painter.drawPort(9, "GT", Direction.WEST);
        painter.drawPort(10, "EQ", Direction.WEST);
        painter.drawPort(11, "Z", Direction.WEST);
        painter.drawPort(12, "N", Direction.WEST);
        painter.drawPort(13, "V", Direction.WEST);
        painter.drawPort(14, "lr_id", Direction.WEST);
        painter.drawLabel();
    }
}

