
// Used for holding a Register's data

package com.sal16.chips;

import com.cburch.logisim.data.BitWidth;
import com.cburch.logisim.data.Value;
import com.cburch.logisim.instance.InstanceData;
import com.cburch.logisim.instance.InstanceState;

class RegisterData implements InstanceData, Cloneable {
    public static RegisterData get(InstanceState state, BitWidth width) {
        RegisterData ret = (RegisterData) state.getData();
        if(ret == null) {
            ret = new RegisterData(Value.createKnown(width, 0));
            state.setData(ret);
        } else if(!ret.val.getBitWidth().equals(width)) {
            ret.val = ret.val.extendWidth(width.getWidth(), Value.FALSE);
        }
        return ret;
    }

    private Value val;

    public RegisterData(Value val) {
        this.val = val;
    }

    public Object clone() {
        try { return super.clone(); }
        catch(CloneNotSupportedException e) { return null; }
    }

    public Value getVal() {
        return val;
    }

    public void setVal(Value val) {
        this.val = val;
    }

    public void reset(BitWidth width) {
        this.val = Value.createKnown(width, 0);
    }

}

