
// Used for holding a Clock's state

package com.sal16.chips;

import com.cburch.logisim.data.BitWidth;
import com.cburch.logisim.data.Value;
import com.cburch.logisim.instance.InstanceData;
import com.cburch.logisim.instance.InstanceState;

class ClockData implements InstanceData, Cloneable {
    private static Value VAL_0 = Value.createKnown(BitWidth.create(1), 0);
    private static Value VAL_1 = Value.createKnown(BitWidth.create(1), 1);

    public static ClockData get(InstanceState state) {
        ClockData ret = (ClockData)state.getData();
        if(ret == null) {
            ret = new ClockData();
            state.setData(ret);
        }
        return ret;
    }

    private Value lastClkIn;
    private Value clk;
    private Value clke;
    private Value clks;
    private int st;

    public ClockData() {
        this.lastClkIn = VAL_0;
        this.clk = VAL_0;
        this.clke = VAL_0;
        this.clks = VAL_0;
        this.st = 0;
    }

    public Object clone() {
        try { return super.clone(); }
        catch(CloneNotSupportedException e) { return null; }
    }

    public void resetClock() {
        lastClkIn = VAL_0;
        clk = VAL_0;
        clke = VAL_0;
        clks = VAL_0;
        st = 0;
    }

    public void updateClock(Value value) {
        Value old = lastClkIn;
        lastClkIn = value;

        boolean rising_edge = (old == Value.FALSE) & (value == Value.TRUE);
        boolean falling_edge = (old == Value.TRUE) & (value == Value.FALSE);

        if (rising_edge) {
            if (st == 0) st = 1;
            if (st == 2) st = 3;
        }
        else if (falling_edge) {
            if (st == 1) st = 2;
            if (st == 3) st = 0;
        }

        switch (st) {
            case 0:
                clk = VAL_0;
                clke = VAL_0;
                clks = VAL_0;
                break;
            case 1:
                clk = VAL_0;
                clke = VAL_1;
                clks = VAL_0;
                break;
            case 2:
                clk = VAL_1;
                clke = VAL_1;
                clks = VAL_1;
                break;
            case 3:
                clk = VAL_1;
                clke = VAL_1;
                clks = VAL_0;
                break;
            default:
                // Shouldn't get here ...
        }
    }

    public Value getClk() {
        return clk;
    }

    public Value getClkE() {
        return clke;
    }

    public Value getClkS() {
        return clks;
    }
}
