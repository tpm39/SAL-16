
// The SAL-16 Address Decoder

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class AddressDecoder extends InstanceFactory {
    private static final int NUM_IO_DEVICES = 16;

    AddressDecoder() {
        super("Address Decoder");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-100, -30, 100, 90));

        setPorts(new Port[] {
                new Port(-100, 0, Port.INPUT, StdAttr.WIDTH),  // addr
                new Port(-100, 30, Port.INPUT, 1),        // ld_gr
                new Port(0, 0, Port.OUTPUT, 1),   // rom
                new Port(0, 20, Port.OUTPUT, 1),    // ram
                new Port(0, 40, Port.OUTPUT, 1)    // i_o
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth() / 2, bds.getY() - 3,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        int addr = state.getPortValue(0).toIntValue();
        int ld_gr = state.getPortValue(1).toIntValue();

        int rom, ram, i_o;
        rom = ram = i_o = 0;

        // The top NUM_IO_DEVICES memory locations are for IO,
        // The bottom half of memory is ROM & the rest is RAM.
        BitWidth nBits = state.getAttributeValue(StdAttr.WIDTH);
        int mem_size = (int)Math.pow(2, nBits.getWidth());
        int io_start = mem_size - NUM_IO_DEVICES;
        int ram_start = mem_size / 2;

        if (ld_gr == 0) {
            if (addr >= io_start) i_o = 1;
            else if (addr >= ram_start) ram = 1;
            else rom = 1;
        }

        Value romv = Value.createKnown(BitWidth.create(1), rom);
        state.setPort(2, romv, 2);
        Value ramv = Value.createKnown(BitWidth.create(1), ram);
        state.setPort(3, ramv, 2);
        Value i_ov = Value.createKnown(BitWidth.create(1), i_o);
        state.setPort(4, i_ov, 2);
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "Addr Decode");
        painter.drawPort(0, "addr", Direction.EAST);
        painter.drawPort(1, "ld_gr", Direction.EAST);
        painter.drawPort(2, "rom", Direction.WEST);
        painter.drawPort(3, "ram", Direction.WEST);
        painter.drawPort(4, "i_o", Direction.WEST);
        painter.drawLabel();
    }
}
