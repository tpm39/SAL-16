
// Used for holding the Stack Pointer's data

package com.sal16.chips;

import com.cburch.logisim.data.BitWidth;
import com.cburch.logisim.data.Value;
import com.cburch.logisim.instance.InstanceData;
import com.cburch.logisim.instance.InstanceState;

class StackPointerData implements InstanceData, Cloneable {
    private final int STACK_MAX = 0xffef;

    public static StackPointerData get(InstanceState state, BitWidth width) {
        StackPointerData ret = (StackPointerData) state.getData();
        if(ret == null) {
            ret = new StackPointerData(width);
            state.setData(ret);
        } else if(!ret.ptr.getBitWidth().equals(width)) {
            ret.ptr = ret.ptr.extendWidth(width.getWidth(), Value.FALSE);
        }
        return ret;
    }

    private Value ptr, th;

    public StackPointerData(BitWidth width) {
        reset(width);
    }

    public Object clone() {
        try { return super.clone(); }
        catch(CloneNotSupportedException e) { return null; }
    }

    public Value getPtr() {
        return ptr;
    }

    public void setPtr(Value ptr) {
        this.ptr = ptr;
    }

    public Value getTopHeap() {
        return th;
    }

    public void setTopHeap(Value th) {
        this.th = th;
    }

    public void reset(BitWidth width) {
        this.ptr = Value.createKnown(width, STACK_MAX);
        this.th = Value.createKnown(width, 0);
    }
}

