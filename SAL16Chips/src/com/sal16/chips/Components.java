
// Chips for use by SAL-16

package com.sal16.chips;

import java.util.Arrays;
import java.util.List;

import com.cburch.logisim.tools.AddTool;
import com.cburch.logisim.tools.Library;

/** The library of components that the user can access. */
public class Components extends Library {
    /** The list of all tools contained in this library. Technically,
     * libraries contain tools, which is a slightly more general concept
     * than components; practically speaking, though, you'll most often want
     * to create AddTools for new components that can be added into the circuit.
     */
    private List<AddTool> tools;

    /** Constructs an instance of this library. This constructor is how
     * Logisim accesses first when it opens the JAR file: It looks for
     * a no-arguments constructor method of the user-designated class.
     */
    public Components() {
        tools = Arrays.asList(
                new AddTool(new Clock()),
                new AddTool(new Register()),
                new AddTool(new ProgramCounter()),
                new AddTool(new StackPointer()),
                new AddTool(new ALU()),
                new AddTool(new MathsUnit()),
                new AddTool(new FPU()),
                new AddTool(new FPScrPos()),
                new AddTool(new Demux_3_to_8()),
                new AddTool(new AddressDecoder()),
                new AddTool(new JumpDecoder()),
                new AddTool(new SetToOne()));
    }

    /** Returns the name of the library that the user will see. */
    public String getDisplayName() {
        return "SAL-16 Chips";
    }

    /** Returns a list of all the tools available in this library. */
    public List<AddTool> getTools() {
        return tools;
    }
}

