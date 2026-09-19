
// Used for holding the Beeper's Trigger state

package com.sal16.chips;

import com.cburch.logisim.data.Value;
import com.cburch.logisim.instance.InstanceData;
import com.cburch.logisim.instance.InstanceState;

class BeeperData implements InstanceData, Cloneable {
    public static BeeperData get(InstanceState state) {
        BeeperData ret = (BeeperData)state.getData();
        if (ret == null) {
            ret = new BeeperData();
            state.setData(ret);
        }
        return ret;
    }

    private Value lastTrigger;

    public BeeperData() {
        lastTrigger = Value.FALSE;
    }

    public Object clone() {
        try { return super.clone(); }
        catch (CloneNotSupportedException e) { return null; }
    }

    public boolean updateTrigger(Value value) {
        Value old = lastTrigger;
        lastTrigger = value;
        return old == Value.TRUE && value == Value.FALSE;
    }
}

