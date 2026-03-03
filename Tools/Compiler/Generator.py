
'''
Generator

Traverse the node tree producing the 
program's assembly code instructions.

'''

import os
import Tokenizer as T
import Node as N

RAM_START = 0x8000
HEAP_START = 0xc000

double_ops = ['++', '+=', '--', '-=', '*=', '/=', '&=', '|=', '^=', '<<', '>>']

# '%' uses the Maths Lib function 'imath_mod' at addr 0x2040
math_mod = 0x2040

# 'globals' indices
GLOBAL_ADDR     = 0
GLOBAL_INIT_VAL = 1
GLOBAL_IS_ARR   = 2
GLOBAL_TYPE     = 3

# 'params' indices
PARAM_INDEX  = 0
PARAM_IS_PTR = 1
PARAM_TYPE   = 2

# 'locals' indices
LOCAL_INDEX    = 0
LOCAL_INIT_VAL = 1
LOCAL_IS_PTR   = 2
LOCAL_IS_ARR   = 3
LOCAL_TYPE     = 4

# Globals
globals = {}      # 'var' : (Address, Initial Value, Array ?, Type), NB: Val for arrays is the array size
params = {}       # 'var' : (Index, Pointer ?, Type)
locals = {}       # 'var' : (Index, Initial Value, Pointer ?, Array ?, Type), NB: Val for arrays is the array size
array_addrs = {}  # 'arr' : Address
array_inits = {}  # 'arr' : [Initial Val 0, Initial Val 1, ...]
var_types_used = set()
next_heap_addr = HEAP_START
fileIn = None
asm = None
lbl_count = 1
func_ret_type = ''
func_has_ret = False

# Create the assembly code from the node list
def generate(nodes, file_in, fileOut, include_files, section):
    global fileIn, includeFiles, asm, globals, params, locals, next_heap_addr
    global func_ret_type, func_has_ret, array_addrs, array_inits, var_types_used

    fileIn = file_in
    includeFiles = include_files

    with open(fileOut, 'w') as asm:
        asm.write(f'\n; Auto-generated assembly code for: {fileIn}\n\n')
        asm.write(f'.{section}\n\n')

        # Add any 'include files'
        if len(include_files) > 0:
            addIncludeFiles()

        # Setup the global variables
        for node in nodes:
            if node.node_type == N.NODE_VAR_INIT:
                var = node.name
                if var in globals:
                    raise SyntaxError(f'Duplicate global variable name, {var},', (fileIn, node.line, 0, ''))

                if node.val_node.node_type == N.NODE_NUMBER:
                    val = node.val_node.num
                elif node.val_node.node_type == N.NODE_CHAR:
                    val = node.val_node.char
                else:
                    var_types_used = set()
                    val = calcInitialValue(node.val_node)

                if node.unary_op == '-':
                    if node.val_node.type == 'int':
                        val = -val
                    elif node.val_node.type == 'float':
                        val |= 0x8000
                    else:
                        raise SyntaxError(f'Can only negate numbers, {var},', (fileIn, node.line, 0, ''))
                elif node.unary_op == '~':
                    val = ~val
                elif node.unary_op == '!':
                    if val == 0:
                        val = 1
                    else:
                        val = 0

                globals[var] = (next_heap_addr, val, False, node.type)
                next_heap_addr += 1

            elif node.node_type == N.NODE_ARRAY_INIT:
                var = node.name
                if var in globals:
                    raise SyntaxError(f'Duplicate global variable name, {var},', (fileIn, node.line, 0, ''))

                if node.dim_node.node_type == N.NODE_NUMBER:
                    size = node.dim_node.num
                elif node.dim_node.node_type == N.NODE_IDENTIFIER and node.dim_node.name in globals:
                    size = globals[node.dim_node.name][GLOBAL_INIT_VAL]
                    if size == 0:
                        raise SyntaxError(f"'{node.dim.name}' must be a 'global constant integer variable' > 0 for the size of array '{var}'", (fileIn, node.line, 0, ''))
                else:
                    raise SyntaxError("Can only use int's or 'global constant integer variables' for array sizes", (fileIn, node.line, 0, ''))

                globals[var] = (next_heap_addr, size, True, node.type)
                next_heap_addr += size

                init_vals = []
                init_num = len(node.arr_vals)
                if init_num > size:
                    raise SyntaxError('The initialisation data exceeds the array size', (fileIn, node.line, 0, ''))

                for i in range(size):
                    if i < init_num:
                        if node.arr_vals[i].node_type == N.NODE_NUMBER:
                            val = node.arr_vals[i].num
                        elif node.arr_vals[i].node_type == N.NODE_CHAR:
                            val = node.arr_vals[i].char
                        else:
                            var_types_used = set()
                            val = calcInitialValue(node.arr_vals[i])
                        init_vals.append(val)
                    else:
                        init_vals.append(0)
                array_inits[var] = init_vals

            else:
                continue

        # Deal with the code section
        asm.write('.code\n\n')

        # First call main() if we're in RAM
        if section.upper() == 'RAM':
            asm.write('   jmp main\n')

        # Deal with all the functions
        for node in nodes:
            if node.node_type == N.NODE_FUNCTION:
                params = {}
                locals = {}
                func_has_ret = False
                func_ret_type = node.ret_type
                name = node.name
                asm.write(f'\n{name}:\n')
                # Push LR, FP & params onto the stack
                asm.write('   push lr\n')
                asm.write('   push fp\n')
                nParams = len(node.param_vals)
                for i in range(nParams, 0, -1):
                    var = node.param_vals[i-1].name
                    params[var] = (i, node.param_vals[i-1].ptr, node.param_vals[i-1].type)
                    asm.write(f'   push r{str(i-1)}\n')
                asm.write('   movsp fp\n')

                # Push the local variables onto the stack
                nLocals = addLocalVariables(node.body)

                # Add the code for the function statements
                processStatements(node.body, name)

                # Return 0 if it's a void function
                if not func_has_ret:
                    asm.write('   clr r0\n')

                asm.write(f'ret_{name}:\n')
                # Pop local variables, params, FP & LR from the stack
                for _ in range(nParams + nLocals):
                    asm.write('   pop idx\n')
                asm.write('   pop fp\n')
                asm.write('   pop lr\n')

                # Return from the function
                if name == 'main':
                    asm.write('   end\n')
                else:
                    asm.write('   ret\n')
            else:
                continue

        # Deal with the data section
        asm.write('\n; Heap\n\n.data\n\n')
        asm.write(f'.= {HEAP_START}\n\n')
        for var in globals:
            if globals[var][GLOBAL_IS_ARR]:
                # Add global arrays to the heap
                array_addrs[var] = globals[var][GLOBAL_ADDR]
                next_addr = globals[var][GLOBAL_ADDR] + globals[var][GLOBAL_INIT_VAL]
                init_vals = array_inits[var]
                for i, val in enumerate(init_vals):
                    if i == 0:
                        asm.write(f'{var}: word {val}\n')
                    else:
                        asm.write(f'{var}_{i}: word {val}\n')
                asm.write(f'\n.= {next_addr}\n\n')
            else:
                # Add global ints to the heap
                val = globals[var][GLOBAL_INIT_VAL]
                if val < 0:
                    # If negative use 2s-complement format
                    val = (val + 0x10000) & 0xffff
                asm.write(f'{var}: word {val}\n')

def addIncludeFiles():
    for file in includeFiles:
        asm.write(f'; {file} functions:\n')
        if file.startswith('./'):
            file = os.getcwd() + '/' + file[2:]
        elif file.startswith('../'):
            file = os.path.dirname(os.getcwd()) + '/' + file[3:]

        with open(file,'r') as f:
            for line in f:
                if line.startswith('.equ'):
                    # Only add function addrs
                    asm.write(line)

        asm.write('\n')

def addLocalVariables(body):
    global locals, params, var_types_used

    idx = 0

    for i in range(len(body.body_lines)):
        node = body.body_lines[i]

        if node.node_type == N.NODE_VAR_INIT:
            init_from_param = False
            var = node.name

            if var in locals:
                raise SyntaxError(f'Duplicate local variable name, {var},', (fileIn, node.line, 0, ''))
            elif var in params:
                raise SyntaxError(f'Local variable name is also a parameter name, {var},', (fileIn, node.line, 0, ''))

            if node.val_node.node_type == N.NODE_NUMBER:
                val = node.val_node.num
            else:
                var_types_used = set()
                if node.val_node.name in params:
                    init_from_param = True
                    val = 0
                else:
                    val = calcInitialValue(node.val_node)

            if node.unary_op == '-':
                if node.val_node.type == 'int':
                    val = -val
                elif node.val_node.type == 'float':
                    val |= 0x8000
                else:
                    raise SyntaxError(f'Can only negate numbers, {var},', (fileIn, node.line, 0, ''))
            elif node.unary_op == '~':
                val = ~val
            elif node.unary_op == '!':
                if val == 0:
                    val = 1
                else:
                    val = 0

            locals[var] = (idx, val, node.ptr, False, node.type)
            idx += 1

            if val == 0:
                asm.write('   clr r0\n')
            else:
                if val < 0:
                    # If negative use 2s-complement format
                    val = (val + 0x10000) & 0xffff
                asm.write(f'   ldi r0,{val}\n')
            asm.write('   push r0\n')

            if init_from_param:
                processVarUpdate(node)

        elif node.node_type == N.NODE_ARRAY_INIT:
            var = node.name

            if var in locals:
                raise SyntaxError(f'Duplicate local variable name, {var},', (fileIn, node.line, 0, ''))

            if node.dim_node.node_type == N.NODE_NUMBER:
                size = node.dim_node.num
            elif node.dim_node.node_type == N.NODE_IDENTIFIER and node.dim_node.name in globals:
                size = globals[node.dim_node.name][GLOBAL_INIT_VAL]
                if size == 0:
                    raise SyntaxError(f"'{node.dim_node.name}' must be a 'constant integer variable' > 0 for the size of array '{var}'", (fileIn, node.line, 0, ''))
            elif node.dim_node.node_type == N.NODE_IDENTIFIER and node.dim_node.name in locals:
                size = locals[node.dim_node.name][LOCAL_INIT_VAL]
                if size == 0:
                    raise SyntaxError(f"'{node.dim_node.name}' must be a 'constant integer variable' > 0 for the size of array '{var}'", (fileIn, node.line, 0, ''))
            else:
                raise SyntaxError("Can only use int's or 'constant integer variables' for array sizes", (fileIn, node.line, 0, ''))

            locals[var] = (idx, size, False, True, node.type)
            idx += size

            init_vals = []
            init_num = len(node.arr_vals)
            if init_num > size:
                raise SyntaxError('The initialisation data exceeds the array size', (fileIn, node.line, 0, ''))

            for i in range(size):
                if i < init_num:
                    if node.arr_vals[i].node_type == N.NODE_NUMBER:
                        val = node.arr_vals[i].num
                    elif node.arr_vals[i].node_type == N.NODE_CHAR:
                        val = node.arr_vals[i].char
                    else:
                        var_types_used = set()
                        val = calcInitialValue(node.arr_vals[i])
                    init_vals.append(val)
                else:
                    init_vals.append(0)

            for val in init_vals:
                asm.write(f'   ldi r0,{val}\n')
                asm.write('   push r0\n')

        else:
            continue

    return idx

def processStatements(body, name, lblBreak=None, lblContinue=None):
    global func_has_ret

    for i in range(len(body.body_lines)):
        node = body.body_lines[i]

        if node.node_type == N.NODE_VAR_INIT:
            continue

        elif node.node_type == N.NODE_ARRAY_INIT:
            continue

        elif node.node_type == N.NODE_VAR_UPDATE:
            processVarUpdate(node)

        elif node.node_type == N.NODE_STATEMENT:
            if node.statement.node_type == N.NODE_BREAK:
                asm.write(f'   jmp {lblBreak}\n')
            elif node.statement.node_type == N.NODE_CONTINUE:
                asm.write(f'   jmp {lblContinue}\n')
            elif node.statement.node_type == N.NODE_RETURN:
                processReturn(node.statement, name)
                func_has_ret = True
            elif node.statement.node_type == N.NODE_WHILE:
                processWhile(node.statement, name)
            elif node.statement.node_type == N.NODE_IF:
                processIf(node.statement, name, lblBreak, lblContinue)
            elif node.statement.node_type == N.NODE_FOR:
                processFor(node.statement, name)
            else:
                raise SyntaxError('Invalid statement', (fileIn, node.line, 0, ''))

        elif node.node_type == N.NODE_FUNC_CALL:
            processFuncCall(node, ret=None)

        elif node.node_type == N.NODE_EXPRESSION:
            if node.op in double_ops:
                node.op = node.op[0]
            else:
                raise SyntaxError("Invalid 'double operator'", (fileIn, node.line, 0, ''))
            update_node = N.Node(N.NODE_VAR_UPDATE)
            update_node.name = node.term_l.name
            node_zero = N.Node(N.NODE_NUMBER)
            node_zero.num = 0
            node_zero.type = 'int'
            node_zero.line = node.line
            update_node.dim_node = node_zero
            update_node.ptr = False
            update_node.val_node = node
            update_node.line = node.line
            processVarUpdate(update_node)

        else:
            raise SyntaxError('Invalid statement', (fileIn, node.line, 0, ''))

def processVarUpdate(node):
    global var_types_used

    func_call = False
    var_types_used = set()

    var_name = node.name
    if var_name in locals:
        var_types_used.add(locals[var_name][LOCAL_TYPE])
    elif var_name in params:
        var_types_used.add(params[var_name][PARAM_TYPE ])
    elif var_name in globals:
        var_types_used.add(globals[var_name][GLOBAL_TYPE])

    if node.val_node.node_type == N.NODE_NUMBER:
        asm.write(f'   ldi r0,{node.val_node.num}\n')
    elif node.val_node.node_type == N.NODE_CHAR:
        asm.write(f'   ldi r0,{node.val_node.char}\n')
    elif node.val_node.node_type == N.NODE_IDENTIFIER:
        if node.unary_op == '&':
            getPtrAddr(node.val_node)
        elif node.unary_op == '*':
            getPtrConts(node.val_node)
        else:
            var_types_used.add(node.val_node.type)
            loadVariable(node.val_node.name, node.val_node.index, 'r0', node.val_node.line)
    elif node.val_node.node_type == N.NODE_EXPRESSION:
        calcExpression(node.val_node)
        asm.write('   pop r0\n')
    else:
        processFuncCall(node.val_node, ret=var_name, index=node.index)
        func_call = True

    if not func_call or node.unary_op is not None:
        if var_name in params and params[var_name][PARAM_IS_PTR]:
            accessArray(var_name, node.index, 'r0', node.line, load=False)
        elif node.ptr:
            storeVarAtPtr(var_name, 'r0', node.line)
        else:
            if node.unary_op is not None and node.unary_op not in ['&', '*']:
                if node.val_node.type == 'char':
                    raise SyntaxError("Unary ops aren't allowed on chars", (fileIn, node.line, 0, ''))
                processUnaryOp(node.unary_op, node.val_node.type)
            storeVariable(var_name, node.index, 'r0', node.line)

    if len(var_types_used) > 1:
        # 'int'/'char' mismatches are allowed, eg: for 'incrementing' through the alphabet
        if var_types_used != {'int', 'char'}:
            raise SyntaxError('Type mismatch when updating a variable', (fileIn, node.line, 0, ''))

def processReturn(node, name):
    global var_types_used

    var_types_used = set()

    if node.expr_node is None:
        # No return value
        asm.write('   clr r0\n')
        asm.write(f'   jmp ret_{name}\n')
        return
    
    else:
        # Return an expression
        node = node.expr_node
        if node.node_type == N.NODE_EXPRESSION:
            if node.op is None and node.term_l.node_type == N.NODE_NUMBER:
                var_types_used.add(node.term_l.type)
                asm.write(f'   ldi r0,{node.term_l.num}\n')
            elif node.op is None and node.term_l.type == N.NODE_IDENTIFIER:
                var_types_used.add(node.term_l.type)
                loadVariable(node.term_l.name, node.term_l.type, 'r0', node.term_l.line)
            else:
                calcExpression(node)
                asm.write('   pop r0\n')
            asm.write(f'   jmp ret_{name}\n')
        else:
            raise SyntaxError('Invalid return value', (fileIn, node.line, 0, ''))

    if len(var_types_used) > 1:
        raise SyntaxError('Type mismatch in return value', (fileIn, node.line, 0, ''))
    
    ret_type = list(var_types_used)[0]
    if ret_type != func_ret_type:
        raise SyntaxError('Type mismatch in return value', (fileIn, node.line, 0, ''))

def processIf(node, name, lblBreak=None, lblContinue=None):
    global lbl_count, var_types_used

    var_types_used = set()
    lbl_if_end = f'if_{name}_{lbl_count}'
    lbl_count += 1
    lbl_else_end = f'if_{name}_{lbl_count}'
    lbl_count += 1

    # Calculate & test the condition
    if node.expr_node.op is None and node.expr_node.unary_op not in T.unary_ops:
        if node.expr_node.term_l.node_type == N.NODE_NUMBER:
            if int(node.expr_node.term_l.num) == 0:
                asm.write(f'   jmp {lbl_if_end}\n')
        else:
            loadVariable(node.expr_node.term_l.name, 0, 'r0', node.line)
            asm.write('   clr r1\n')
            asm.write('   cmp r0,r1\n')
            asm.write(f'   jeq {lbl_if_end}\n')
    else:
        calcExpression(node.expr_node, name=name)
        asm.write('   pop r0\n')
        asm.write('   clr r1\n')
        asm.write('   cmp r0,r1\n')
        asm.write(f'   jeq {lbl_if_end}\n')

    # Perform the stuff in the 'if' body
    processStatements(node.body_if, name, lblBreak, lblContinue)
    if node.body_else is not None:
        asm.write(f'   jmp {lbl_else_end}\n')
        asm.write(f'{lbl_if_end}:\n')

        # Perform the stuff in the 'else' body
        processStatements(node.body_else, name, lblBreak, lblContinue)
        asm.write(f'{lbl_else_end}:\n')
    else:
        asm.write(f'{lbl_if_end}:\n')

def processWhile(node, name):
    global lbl_count, var_types_used

    var_types_used = set()
    lbl_start = f'while_{name}_{lbl_count}'
    lbl_count += 1
    lbl_done = f'while_{name}_{lbl_count}'
    lbl_count += 1

    asm.write(f'{lbl_start}:\n')

    # Calculate & test the condition
    if node.expr_node.op is None and node.expr_node.unary_op not in T.unary_ops:
        if node.expr_node.term_l.node_type == N.NODE_NUMBER:
            if int(node.expr_node.term_l.num) == 0:
                asm.write(f'   jmp {lbl_done}\n')
        else:
            loadVariable(node.expr_node.term_l.name, 0, 'r0', node.line)
            asm.write('   clr r1\n')
            asm.write('   cmp r0,r1\n')
            asm.write(f'   jeq {lbl_done}\n')
    else:
        calcExpression(node.expr_node, name=name)
        asm.write('   pop r0\n')
        asm.write('   clr r1\n')
        asm.write('   cmp r0,r1\n')
        asm.write(f'   jeq {lbl_done}\n')

    # Perform the stuff in the body
    processStatements(node.body, name, lblBreak=lbl_done, lblContinue=lbl_start)
    asm.write(f'   jmp {lbl_start}\n')
    asm.write(f'{lbl_done}:\n')

def processFor(node, name):
    global lbl_count, var_types_used

    var_types_used = set()
    lbl_start = f'for_{name}_{lbl_count}'
    lbl_count += 1
    lbl_test = f'for_{name}_{lbl_count}'
    lbl_count += 1
    lbl_done = f'for_{name}_{lbl_count}'
    lbl_count += 1

    # Initialise the loop variable
    if node.for_init is not None:
        processVarUpdate(node.for_init)

    asm.write(f'{lbl_start}:\n')

    # Calculate & test the condition
    if node.for_expr is not None:
        if node.for_expr.op is None and node.for_expr.unary_op not in T.unary_ops:
            if node.for_expr.term_l.node_type == N.NODE_NUMBER:
                if int(node.for_expr.term_l.num) == 0:
                    asm.write(f'   jmp {lbl_done}\n')
            else:
                loadVariable(node.for_expr.term_l.name, 0, 'r0', node.line)
                asm.write('   clr r01\n')
                asm.write('   cmp r0,r1\n')
                asm.write(f'   jeq {lbl_done}\n')
        else:
            calcExpression(node.for_expr, name=name)
            asm.write('   pop r0\n')
            asm.write('   clr r1\n')
            asm.write('   cmp r0,r1\n')
            asm.write(f'   jeq {lbl_done}\n')

    # Perform the stuff in the body
    processStatements(node.body, name, lblBreak=lbl_done, lblContinue=lbl_test)

    # Update the loop variable
    asm.write(f'{lbl_test}:\n')
    if node.for_update is not None:
        processVarUpdate(node.for_update)

    asm.write(f'   jmp {lbl_start}\n')
    asm.write(f'{lbl_done}:\n')

def processFuncCall(node, ret=None, index=0):
    nParams = len(node.param_vals)
    for i in range(nParams):
        reg = f'r{i}'
        if node.param_vals[i].node_type == N.NODE_IDENTIFIER:
            # If an array use address
            if node.param_vals[i].name in array_addrs:
                addr = array_addrs[node.param_vals[i].name]
                asm.write(f'   ldi {reg},{addr}\n')
            else:
                loadVariable(node.param_vals[i].name, node.param_vals[i].index, reg, node.line)
        else: # The parameter is a number or a char
            if node.param_vals[i].node_type == N.NODE_NUMBER:
                num = int(node.param_vals[i].num)
                if num < 0:
                    # If negative use 2s-complement format
                    num = (num + 0x10000) & 0xffff
                asm.write(f'   ldi {reg},{num}\n')
            else:
                char = int(node.param_vals[i].char)
                asm.write(f'   ldi {reg},{char}\n')
    asm.write(f'   call {node.name}\n')
    if ret is not None:
        storeVariable(ret, index, 'r0', node.line)

def loadVariable(name, arr_index, reg, lineNo):
    accessVariable(name, arr_index, reg, lineNo, load=True)

def storeVariable(name, arr_index, reg, lineNo):
    accessVariable(name, arr_index, reg, lineNo, load=False)

def accessVariable(name, arr_index, reg, lineNo, load=True):
    if name in locals:
        if locals[name][LOCAL_IS_ARR]:
            accessArray(name, arr_index, reg, lineNo, load)
        else:
            # Get the array index as an int
            if arr_index is None or isinstance(arr_index, str):
                # A pointer isn't being used to access an array in these cases
                arr_index = -1
            elif not isinstance(arr_index, int):
                # Get the NODE_NUMBER's value
                arr_index = arr_index.num

            if locals[name][LOCAL_IS_PTR] and arr_index >= 0:
                # A pointer is being used to access an array
                asm.write(f'   ldi idx,{-locals[name][LOCAL_INDEX]}\n')
                asm.write(f'   add fp,idx,idx\n')
                asm.write(f'   ld idx,[idx]\n')
                asm.write(f'   ldi r4,{arr_index}\n')
                asm.write(f'   add idx,r4,idx\n')
                if load:
                    asm.write(f'   ld {reg},[idx]\n')
                else:
                    asm.write(f'   st {reg},[idx]\n')
            else:
                asm.write(f'   ldi idx,{-locals[name][LOCAL_INDEX]}\n')
                if load:
                    asm.write(f'   ldx {reg},[fp,idx]\n')
                else:
                    asm.write(f'   stx {reg},[fp,idx]\n')

    elif name in params:
        asm.write(f'   ldi idx,{params[name][PARAM_INDEX]}\n')
        if load:
            asm.write(f'   ldx {reg},[fp,idx]\n')
        else:
            asm.write(f'   stx {reg},[fp,idx]\n')

    elif name in globals:
        if globals[name][GLOBAL_IS_ARR]:
            accessArray(name, arr_index, reg, lineNo, load)
        else:
            asm.write(f'   ldi idx,{name}\n')
            if load:
                asm.write(f'   ld {reg},[idx]\n')
            else:
                asm.write(f'   st {reg},[idx]\n')

    else:
        raise SyntaxError(f'Invalid variable identifier: {name}', (fileIn, lineNo, 0, ''))

def accessArray(array, index, reg, lineNo, load=True):
    if array in locals:
        asm.write(f'   ldi idx,{-locals[array][LOCAL_INDEX]}\n')
        asm.write(f'   add fp,idx,idx\n')
    elif array in params:
        asm.write(f'   ldi idx,{params[array][PARAM_INDEX]}\n')
        asm.write(f'   ldx idx,[fp,idx]\n')
    elif array in globals:
        asm.write(f'   ldi idx,{array}\n')
    else:
        raise SyntaxError(f'Invalid array identifier: {array}', (fileIn, lineNo, 0, ''))

    if isinstance(index, int):
        if index > 0:
            if array in locals:
                asm.write(f'   ldi r4,{-index}\n')
            else:
                asm.write(f'   ldi r4,{index}\n')
            asm.write('   add r4,idx,idx\n')
    elif isinstance(index, str):
        asm.write('   push idx\n')
        loadVariable(index, 0, 'r4', lineNo)
        if array in locals:
            # locals need a 'negative index' to go down the stack
            asm.write('   not r4,r4\n')
            asm.write('   inc r4\n')
        asm.write('   pop idx\n')
        asm.write('   add r4,idx,idx\n')
    else:
        if index.node_type == N.NODE_NUMBER:
            if index.num > 0:
                if array in locals:
                    asm.write(f'   ldi r4,{-index.num}\n')
                else:
                    asm.write(f'   ldi r4,{index.num}\n')
                asm.write('   add r4,idx,idx\n')
        else:
            asm.write('   push idx\n')
            loadVariable(index.name, 0, 'r4', lineNo)
            if array in locals:
                # locals need a 'negative index' to go down the stack
                asm.write('   not r4,r4\n')
                asm.write('   inc r4\n')
            asm.write('   pop idx\n')
            asm.write('   add r4,idx,idx\n')
    if load:
        asm.write(f'   ld {reg},[idx]\n')
    else:
        asm.write(f'   st {reg},[idx]\n')

def float_to_dec(val, node):
    # Extract the sign bit, exponent & mantissa
    sign = (val & 0x8000) >> 15
    exp = (val & 0x7c00) >> 10
    mant = (val & 0x03ff)
    mantStr = f'{mant:010b}'

    # Convert the mantissa to its floating point value
    mantVal = 0
    for i in range(10):
        if mantStr[i] == '1':
            mantVal += 1/(2**(i+1))

    # Deal with Subnormal numbers & zero
    if exp == 0:
        if mant == 0:
            # Zero
            dec = 0
        else:
            # Subnormal
            dec = ((-1)**sign) * (2**(-14)) * mantVal

    # Deal with numbers beyond the Normal/Subnormal limits
    elif exp == 0x1f:
        raise SyntaxError(f'Infinity or NaN when calculating {node.num}', (fileIn, node.line, 0, ''))
            
    # Deal with normal numbers
    else:
        dec = ((-1)**sign) * (2**(exp - 15)) * (1 + mantVal)

    return dec

def calcInitialValue(node):
    # Get rid of 'outer brackets'
    while node.op is None and node.node_type == N.NODE_EXPRESSION:
        node = node.term_l

    if node.node_type == N.NODE_NUMBER:
        val = node.num
        var_type = node.type
        var_types_used.add(var_type)
        if var_type == 'float':
            val = float_to_dec(val, node)

    elif node.node_type == N.NODE_CHAR:
        val = node.char
        var_type = node.type
        var_types_used.add(var_type)

    elif node.node_type == N.NODE_IDENTIFIER:
        if node.name in locals:
            val = locals[node.name][LOCAL_INIT_VAL]
        elif node.name in params:
            raise SyntaxError(f"Function parameters don't have 'hard initial values': {node.name}", (fileIn, node.line, 0, ''))
        elif node.name in globals:
            val = globals[node.name][GLOBAL_INIT_VAL]
        else:
            raise SyntaxError(f'Undefined variable: {node.name}', (fileIn, node.line, 0, ''))

        var_type = node.type
        var_types_used.add(var_type)
        if var_type == 'float':
            val = float_to_dec(val, node)

    else:
        lval = calcInitialValue(node.term_l)
        rval = calcInitialValue(node.term_r)
        if len(var_types_used) > 1:
            raise SyntaxError("Type mismatch when calculating the variable's value", (fileIn, node.line, 0, ''))

        if node.op == '+':
            val = lval + rval
        elif node.op == '-':
            val = lval - rval
        elif node.op == '*':
            val = lval * rval
        elif node.op == '/':
            if rval == 0:
                raise SyntaxError('Division by 0', (fileIn, node.line, 0, ''))
            var_type = list(var_types_used)[0]
            if var_type == 'int':
                val = lval // rval
            elif var_type == 'float':
                val = lval / rval
        elif node.op == '%':
            val = lval % rval
        elif node.op == '&':
            val = lval & rval
        elif node.op == '|':
            val = lval | rval
        elif node.op == '^':
            val = lval ^ rval
        else:
            raise SyntaxError(f'Invalid operator, {node.op},', (fileIn, node.line, 0, ''))

    return val

def calcExpression(node, name=None):
    global lbl_count, var_types_used

    # Get rid of 'outer brackets'
    unary_op = node.unary_op
    while node.op is None and node.node_type == N.NODE_EXPRESSION:
        unary_op = node.unary_op
        node = node.term_l

    if node.node_type == N.NODE_NUMBER:
        var_types_used.add(node.type)
        asm.write(f'   ldi r0,{node.num}\n')
        processUnaryOp(unary_op, node.type)
        asm.write('   push r0\n')
        return
    
    elif node.node_type == N.NODE_CHAR:
        var_types_used.add(node.type)
        asm.write(f'   ldi r0,{node.char}\n')
        processUnaryOp(unary_op, node.type)
        asm.write('   push r0\n')
        return
    
    elif node.node_type == N.NODE_IDENTIFIER:
        var_types_used.add(node.type)
        if unary_op == '&':
            getPtrAddr(node)
        elif unary_op == '*':
            getPtrConts(node)
        elif node.ptr or (node.name in params and params[node.name][PARAM_IS_PTR]):
            getPtr(node)
            asm.write('   mov r0,r1\n')
            asm.write('   ld r0,[r1]\n')
        else:
            loadVariable(node.name, node.index, 'r0', node.line)
        processUnaryOp(unary_op, node.type)
        asm.write('   push r0\n')
        return
    
    else:
        calcExpression(node.term_l)

    if node.term_r.node_type == N.NODE_NUMBER:
        var_types_used.add(node.term_r.type)
        asm.write(f'   ldi r0,{node.term_r.num}\n')
        asm.write('   push r0\n')

    elif node.term_r.node_type == N.NODE_IDENTIFIER:
        var_types_used.add(node.term_r.type)
        if node.term_r.ptr or (node.term_r.name in params and params[node.term_r.name][PARAM_IS_PTR]):
            getPtr(node.term_r)
            asm.write('   mov r0,r1\n')
            asm.write('   ld r0,[r1]\n')
        else:
            loadVariable(node.term_r.name, node.term_r.index, 'r0', node.term_r.line)
        asm.write('   push r0\n')

    elif node.term_r.node_type == N.NODE_EXPRESSION:
        calcExpression(node.term_r)

    asm.write('   pop r1\n')
    asm.write('   pop r0\n')

    if 'char' in var_types_used and node.op in ['*', '/', '%', '&', '|', '^', '<<', '>>']:
        raise SyntaxError(f"Invalid 'char' operator: '{node.op}'", (fileIn, node.line, 0, ''))

    var_type = list(var_types_used)[0]

    if node.op == '+':
        if var_type in ['int', 'char']:
            asm.write('   add r0,r1,r0\n')
        else:
            asm.write('   fadd r0,r1,r0\n')
    elif node.op == '-':
        if var_type in ['int', 'char']:
            asm.write('   sub r0,r1,r0\n')
        else:
            asm.write('   fsub r0,r1,r0\n')
    elif node.op == '*':
        if var_type == 'int':
            asm.write('   mul r0,r1,r0\n')
        else:
            asm.write('   fmul r0,r1,r0\n')
    elif node.op == '/':
        if var_type == 'int':
            asm.write('   sdiv r0,r1,r0\n')
        else:
            asm.write('   fdiv r0,r1,r0\n')
    elif node.op == '%':
        asm.write(f'   call {math_mod}\n')
    elif node.op == '&':
        asm.write('   and r0,r1,r0\n')
    elif node.op == '|':
        asm.write('   or r0,r1,r0\n')
    elif node.op == '^':
        asm.write('   xor r0,r1,r0\n')
    elif node.op == '<<':
        asm.write('   lsl r0,r1,r0\n')
    elif node.op == '>>':
        asm.write('   lsr r0,r1,r0\n')
    elif node.op == '&&':
        label = f'cond_{name}_{lbl_count}'
        lbl_count += 1
        asm.write('   clr r2\n')
        asm.write('   clr r3\n')
        asm.write('   cmp r0,r3\n')
        asm.write(f'   jeq {label}\n')
        asm.write('   cmp r1,r3\n')
        asm.write(f'   jeq {label}\n')
        asm.write('   inc r2\n')
        asm.write(f'{label}:\n')
        asm.write('   mov r2,r0\n')
    elif node.op == '||':
        label = f'cond_{name}_{lbl_count}'
        lbl_count += 1
        asm.write('   ldi r2,1\n')
        asm.write('   clr r3\n')
        asm.write('   cmp r0,r3\n')
        asm.write(f'   jgt {label}\n')
        asm.write('   cmp r1,r3\n')
        asm.write(f'   jgt {label}\n')
        asm.write('   clr r2\n')
        asm.write(f'{label}:\n')
        asm.write('   mov r2,r0\n')
    elif node.op == '==':
        label = f'cond_{name}_{lbl_count}'
        lbl_count += 1
        asm.write('   ldi r2,1\n')
        asm.write('   cmp r0,r1\n')
        asm.write(f'   jeq {label}\n')
        asm.write('   clr r2\n')
        asm.write(f'{label}:\n')
        asm.write('   mov r2,r0\n')
    elif node.op == '!=':
        label = f'cond_{name}_{lbl_count}'
        lbl_count += 1
        asm.write('   clr r2\n')
        asm.write('   cmp r0,r1\n')
        asm.write(f'   jeq {label}\n')
        asm.write('   inc r2\n')
        asm.write(f'{label}:\n')
        asm.write('   mov r2,r0\n')
    elif node.op == '<':
        label = f'cond_{name}_{lbl_count}'
        lbl_count += 2
        asm.write('   ldi r2,1\n')
        if var_type == 'int':
            asm.write('   cmp r1,r0\n')
        else:
            asm.write('   fcmp r1,r0\n')
        asm.write(f'   jgt {label}\n')
        asm.write('   clr r2\n')
        asm.write(f'{label}:\n')
        asm.write('   mov r2,r0\n')
    elif node.op == '<=':
        label = f'cond_{name}_{lbl_count}'
        lbl_count += 2
        asm.write('   ldi r2,1\n')
        if var_type == 'int':
            asm.write('   cmp r1,r0\n')
        else:
            asm.write('   fcmp r1,r0\n')
        asm.write(f'   jge {label}\n')
        asm.write('   clr r2\n')
        asm.write(f'{label}:\n')
        asm.write('   mov r2,r0\n')
    elif node.op == '>':
        label = f'cond_{name}_{lbl_count}'
        lbl_count += 2
        asm.write('   ldi r2,1\n')
        if var_type == 'int':
            asm.write('   cmp r0,r1\n')
        else:
            asm.write('   fcmp r0,r1\n')
        asm.write(f'   jgt {label}\n')
        asm.write('   clr r2\n')
        asm.write(f'{label}:\n')
        asm.write('   mov r2,r0\n')
    elif node.op == '>=':
        label = f'cond_{name}_{lbl_count}'
        lbl_count += 2
        asm.write('   ldi r2,1\n')
        if var_type == 'int':
            asm.write('   cmp r0,r1\n')
        else:
            asm.write('   fcmp r0,r1\n')
        asm.write(f'   jge {label}\n')
        asm.write('   clr r2\n')
        asm.write(f'{label}:\n')
        asm.write('   mov r2,r0\n')
    else:
        raise SyntaxError(f'Invalid operator, {node.op},', (fileIn, node.line, 0, ''))

    processUnaryOp(unary_op, var_type)

    asm.write('   push r0\n')

def processUnaryOp(op, var_type):
    global lbl_count

    if op == '-':
        if var_type == 'int':
            asm.write('   not r0,r0\n')
            asm.write('   inc r0\n')
        elif var_type == 'float':
            asm.write('   ldi r1,0x8000\n')
            asm.write('   or r0,r1,r0\n')
    elif op == '~':
        asm.write('   not r0,r0\n')
    elif op == '!':
        lbl_not_is_0 = f'not_is_0_{lbl_count}'
        lbl_count += 1
        asm.write('   clr r1\n')
        asm.write('   cmp r0,r1\n')
        asm.write(f'   jgt {lbl_not_is_0}\n')
        asm.write('   inc r1\n')
        asm.write(f'{lbl_not_is_0}:\n')
        asm.write('   mov r1,r0\n')

def getPtr(node):
    if node.node_type != N.NODE_IDENTIFIER:
        raise SyntaxError('Can only get the address of a variable', (fileIn, node.line, 0, ''))

    var = node.name
    if var in locals:
        if var in array_addrs:
            asm.write(f'   ldi r0,{array_addrs[var]}\n')
        else:
            asm.write(f'   ldi idx,{-locals[var][LOCAL_INDEX]}\n')
            asm.write(f'   ldx r0,[fp,idx]\n')

    elif var in params:
        asm.write(f'   ldi idx,{params[var][PARAM_INDEX]}\n')
        asm.write(f'   ldx r0,[fp,idx]\n')
        if isinstance(node.index, int):
            asm.write(f'   ldi r1,{node.index}\n')
        elif isinstance(node.index, str):
            loadVariable(node.index, 0, 'r1', node.line)
        else:
            if node.index.node_type == N.NODE_NUMBER:
                asm.write(f'   ldi r1,{node.index.num}\n')
            else:
                loadVariable(node.index, 0, 'r1', node.index.line)
        asm.write('   add r0,r1,r0\n')

    elif var in globals:
        asm.write(f'   ldi r0,{globals[var][GLOBAL_ADDR]}\n')

    else:
        raise SyntaxError(f'Undefined variable when getting pointer: {var}', (fileIn, node.line, 0, ''))

def getPtrAddr(node):
    if node.node_type != N.NODE_IDENTIFIER:
        raise SyntaxError('Can only get the address of a variable', (fileIn, node.line, 0, ''))

    var = node.name
    if var in locals:
        if var in array_addrs:
            asm.write(f'   ldi r0,{array_addrs[var]}\n')
        else:
            asm.write(f'   ldi idx,{-locals[var][LOCAL_INDEX]}\n')
            asm.write(f'   add fp,idx,r0\n')

    elif var in params:
        asm.write(f'   ldi idx,{params[var][PARAM_INDEX]}\n')
        asm.write(f'   add fp,idx,r0\n')

    elif var in globals:
        asm.write(f'   ldi r0,{globals[var][GLOBAL_ADDR]}\n')

    else:
        raise SyntaxError(f'Undefined variable when getting pointer address: {var}', (fileIn, node.line, 0, ''))

def getPtrConts(node):
    getPtr(node)
    asm.write(f'   ld r0,[r0]\n')

    if node.name in locals:
        pass
    elif node.name in params:
        pass
    elif node.name in globals:
        asm.write(f'   ld r0,[r0]\n')
    else:
        raise SyntaxError(f'Undefined variable when getting pointer contents: {node.name}', (fileIn, node.line, 0, ''))

def storeVarAtPtr(ptr, reg, lineNo):
    if ptr in locals:
        asm.write(f'   ldi idx,{-locals[ptr][LOCAL_INDEX]}\n')
        asm.write(f'   ldx idx,[fp,idx]\n')
        asm.write(f'   st {reg},[idx]\n')
    elif ptr in params:
        asm.write(f'   ldi idx,{params[ptr][PARAM_INDEX]}\n')
        asm.write(f'   ldx idx,[fp,idx]\n')
        asm.write(f'   st {reg},[idx]\n')
    elif ptr in globals:
        loadVariable(ptr, 0, 'r4', lineNo)
        asm.write('   mov r4,idx\n')
        asm.write(f'   st {reg},[idx]\n')
    else:
        raise SyntaxError(f'Invalid pointer variable: {ptr},', (fileIn, lineNo, 0, ''))

