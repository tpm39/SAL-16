
// The SAL-16 Clock

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

class Clock extends InstanceFactory {
    Clock() {
        super("Clock");

        setAttributes(
                new Attribute[] { StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(-80, -30, 80, 80));

        setPorts(new Port[] {
                new Port(-80, 0, Port.INPUT, 1),   // reset
                new Port(-80, 20, Port.INPUT, 1),  // clkin
                new Port(-80, 40, Port.INPUT, 1),  // init
                new Port(0, 0, Port.OUTPUT, 1),    // clk
                new Port(0, 20, Port.OUTPUT, 1),   // clks
                new Port(0, 40, Port.OUTPUT, 1),   // clke
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth()/2, bds.getY() + bds.getHeight()/2 + 10,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        ClockData cur = ClockData.get(state);
        int reset = state.getPortValue(0).toIntValue();

        if (reset == 1) {
            cur.resetClock();
        }
        else {
            cur.updateClock(state.getPortValue(1));
            state.setPort(3, cur.getClk(), 9);
            state.setPort(4, cur.getClkS(), 9);
            state.setPort(5, cur.getClkE(), 9);
        }
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "Clock");
        painter.drawPort(0, "reset", Direction.EAST);
        painter.drawPort(1, "clkin", Direction.EAST);
        painter.drawPort(2, "init", Direction.EAST);
        painter.drawPort(3, "clk", Direction.WEST);
        painter.drawPort(4, "clks", Direction.WEST);
        painter.drawPort(5, "clke", Direction.WEST);
        painter.drawLabel();
    }
}
