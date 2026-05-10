
// Used for holding the Program Counter's data

package com.sal16.chips;

import com.cburch.logisim.data.BitWidth;
import com.cburch.logisim.data.Value;
import com.cburch.logisim.instance.InstanceData;
import com.cburch.logisim.instance.InstanceState;

class ProgramCounterData implements InstanceData, Cloneable {
    public static ProgramCounterData get(InstanceState state, BitWidth width) {
        ProgramCounterData ret = (ProgramCounterData) state.getData();
        if(ret == null) {
            ret = new ProgramCounterData(Value.createKnown(width, 0), Value.createKnown(width, 0));
            state.setData(ret);
        } else if(!ret.conts.getBitWidth().equals(width)) {
            ret.conts = ret.conts.extendWidth(width.getWidth(), Value.FALSE);
            ret.saved = ret.saved.extendWidth(width.getWidth(), Value.FALSE);
        }
        return ret;
    }

    private Value conts, saved;

    public ProgramCounterData(Value conts, Value saved) {
        this.conts = conts;
        this.saved = saved;
    }

    public Object clone() {
        try { return super.clone(); }
        catch(CloneNotSupportedException e) { return null; }
    }

    public Value getConts() {
        return conts;
    }

    public void setConts(Value conts) {
        this.conts = conts;
    }

    public Value getSaved() {
        return saved;
    }

    public void setSaved(Value saved) {
        this.saved = saved;
    }

    public void reset(BitWidth width) {
        this.conts = Value.createKnown(width, 0);
        this.saved = Value.createKnown(width, 0);
    }
}

