
'''
Parser

Go through the tokens list and create a
'node tree' of the program's instructions.

'''

import os
import Tokenizer as T
import Node as N

# Globals
tokens = []
global_var_types = {}
param_var_types = {}
local_var_types = {}
in_func = False
func_ret_types = {}
func_ret_type = ''
func_has_ret_val = False
fileIn = None

# Get a variable's type
def getVarType(var, lineNo):
    if in_func and var in local_var_types:
        var_type = local_var_types[var]
    elif in_func and var in param_var_types:
        var_type = param_var_types[var]
    elif var in global_var_types:
        var_type = global_var_types[var]
    else:
        raise SyntaxError(f'Udefined variable: {var}', (fileIn, lineNo, 0, ''))

    return var_type

# Set the return types of all '#include' functions to 'any'
def setIncludeFuncTypes(files):
    global func_ret_types

    for file in files:
        if file.startswith('./'):
            file = os.getcwd() + '/' + file[2:]
        elif file.startswith('../'):
            file = os.path.dirname(os.getcwd()) + '/' + file[3:]

        with open(file,'r') as f:
            for line in f:
                if line.startswith('.equ'):
                    line = line.split(' ')
                    func_ret_types[line[1]] = 'any'

# Create the node tree
def parse(token_list, file_in, include_files):
    global tokens, fileIn
    nodes = []
    tokens = token_list
    tok_ptr = 0
    fileIn = file_in

    setIncludeFuncTypes(include_files)

    while tok_ptr < len(tokens):
        if tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_KEYWORD and tokens[tok_ptr][T.TOKEN_VAL] in ['int', 'float', 'char', 'void']:
            if tokens[tok_ptr+2][T.TOKEN_VAL] == '(':
                node, tok_ptr = parseFunction(tok_ptr)
                nodes.append(node)
            elif tokens[tok_ptr+2][T.TOKEN_VAL] == '[':
                node, tok_ptr = parseArrayInit(tok_ptr)
                nodes.append(node)
            else:
                var_nodes, tok_ptr = parseVariableInit(tok_ptr)
                for node in var_nodes:
                    nodes.append(node)
        else:
            raise SyntaxError('Expecting variable or function declaration', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        tok_ptr += 1

    return nodes

def parseVariableInit(tok_ptr):
    # Var Init format:
    #   ('int' | 'float' | 'char') ('*')? name ((',' name)* | ('=' (unary_op)? expr)) ';' 

    # Var Init node:
    #   NODE_VAR_INIT, name, type, is_ptr, unary_op, (NODE_NUMBER | NODE_CHAR | NODE_IDENTIFIER | NODE_EXPRESSION), line
    global in_func, local_var_types, global_var_types

    var_nodes = []
    node = N.Node(N.NODE_VAR_INIT)

    var_type = tokens[tok_ptr][T.TOKEN_VAL]
    if var_type not in ['int', 'float', 'char']:
        raise SyntaxError('Invalid variable type', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    ptr = False
    if tokens[tok_ptr+1][T.TOKEN_VAL] == '*':
        ptr = True
        tok_ptr += 1

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_IDENTIFIER:
        raise SyntaxError('Expected identifier after type in variable declaration', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
    var_name = tokens[tok_ptr][T.TOKEN_VAL]
    node.name = var_name
    if in_func:
        local_var_types[var_name] = var_type
    else:
        global_var_types[var_name] = var_type
    node.ptr = ptr

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] == '=':
        tok_ptr += 1

        if var_type != 'char' and tokens[tok_ptr][T.TOKEN_VAL] in T.unary_ops:
            node.unary_op = tokens[tok_ptr][T.TOKEN_VAL]
            tok_ptr += 1

        if tokens[tok_ptr+1][T.TOKEN_VAL] != ';':
            var_node, tok_ptr = parseExpression(tok_ptr)
        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_NUMBER:
            if var_type != 'int':
                raise SyntaxError('Invalid variable type', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
            var_node = N.Node(N.NODE_NUMBER)
            var_node.num = int(tokens[tok_ptr][T.TOKEN_VAL])
            var_node.type = 'int'
            var_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            tok_ptr += 1
        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_FLOAT:
            if var_type != 'float':
                raise SyntaxError('Invalid variable type', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
            var_node = N.Node(N.NODE_NUMBER)
            var_node.num = int(tokens[tok_ptr][T.TOKEN_VAL])
            var_node.type = 'float'
            var_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            tok_ptr += 1
        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_CHAR:
            if var_type != 'char':
                raise SyntaxError('Invalid variable type', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
            var_node = N.Node(N.NODE_CHAR)
            var_node.char = ord(tokens[tok_ptr][T.TOKEN_VAL])
            var_node.type = 'char'
            var_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            tok_ptr += 1
        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
            var_node = N.Node(N.NODE_IDENTIFIER)
            var_node.name = tokens[tok_ptr][T.TOKEN_VAL]
            var_node.ptr = False
            var_node.type = var_type
            var_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            tok_ptr += 1
        else:
            raise SyntaxError('Require a number or a variable for variable initialisation', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        node.val_node = var_node
        node.type = var_type
        node.line = tokens[tok_ptr][T.TOKEN_LINE]
        var_nodes.append(node)
    else:
        line = tokens[tok_ptr][T.TOKEN_LINE]

        var_node = N.Node(N.NODE_NUMBER)
        var_node.num = 0
        var_node.type = var_type
        var_node.line = line

        node.val_node = var_node
        node.type = var_type
        node.line = line
        var_nodes.append(node)

        while tokens[tok_ptr][T.TOKEN_VAL] == ',':
            node = N.Node(N.NODE_VAR_INIT)
            tok_ptr += 1
            if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_IDENTIFIER:
                raise SyntaxError('Expected identifier after type in variable declaration', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

            var_name = tokens[tok_ptr][T.TOKEN_VAL]
            node.name = var_name
            if in_func:
                local_var_types[var_name] = var_type
            else:
                global_var_types[var_name] = var_type

            node.ptr = ptr
            line = tokens[tok_ptr][T.TOKEN_LINE]

            var_node = N.Node(N.NODE_NUMBER)
            var_node.num = 0
            var_node.type = var_type
            var_node.line = line

            node.val_node = var_node
            node.type = var_type
            node.line = line
            var_nodes.append(node)
            tok_ptr += 1

    if tokens[tok_ptr][T.TOKEN_VAL] != ';':
        if tokens[tok_ptr][T.TOKEN_VAL] == ')':
            raise SyntaxError("Invalid expression", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        else:
            raise SyntaxError('Unterminated variable declaration', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    return (var_nodes, tok_ptr)

def parseArrayInit(tok_ptr):
    # Array Init format:
    #   ('int' | 'float' | 'char') name '[' (num)? ']' ('=' '{' num|name (',' num|name)* '}')? ';' 

    # Array Init node:
    #   NODE_ARRAY_INIT, name, type, NODE_NUMBER | NODE_IDENTIFIER, (NODE_NUMBER | NODE_CHAR | NODE_IDENTIFIER)*, line

    node = N.Node(N.NODE_ARRAY_INIT)

    arr_type = tokens[tok_ptr][T.TOKEN_VAL]
    if arr_type not in ['int', 'float', 'char']:
        raise SyntaxError('Invalid array type', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_IDENTIFIER:
        raise SyntaxError("Expected identifier after 'type'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    arr_name = tokens[tok_ptr][T.TOKEN_VAL]
    if in_func:
        local_var_types[arr_name] = arr_type
    else:
        global_var_types[arr_name] = arr_type

    node.name = arr_name

    # Already dealt with '['
    tok_ptr += 2
    if tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_NUMBER:
        arr_size = N.Node(N.NODE_NUMBER)
        arr_size.num = int(tokens[tok_ptr][T.TOKEN_VAL])
        arr_size.type = 'int'
        arr_size.line = tokens[tok_ptr][T.TOKEN_LINE]
    elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
        size_name = tokens[tok_ptr][T.TOKEN_VAL]
        size_type = getVarType(size_name, tokens[tok_ptr][T.TOKEN_LINE])
        if size_type != 'int':
            raise SyntaxError("Can only use int's for array sizes", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        arr_size = N.Node(N.NODE_IDENTIFIER)
        arr_size.name = size_name
        arr_size.ptr = False
        arr_size.type = size_type
        arr_size.line = tokens[tok_ptr][T.TOKEN_LINE]

    elif tokens[tok_ptr][T.TOKEN_VAL] == ']':
        arr_size = None
        tok_ptr -= 1
    else:
        raise SyntaxError("Can only use int's or 'global constant integer variables' for array sizes", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != ']':
        raise SyntaxError("Missing ']' in array declaration", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] == ';':
        if arr_size is None:
            raise SyntaxError('Missing array size in array declaration', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        node.dim_node = arr_size
        node.arr_vals = []
        node.type = arr_type
        node.line = tokens[tok_ptr][T.TOKEN_LINE]
        return (node, tok_ptr)

    elif tokens[tok_ptr][T.TOKEN_VAL] != '=':
        raise SyntaxError("Missing '=' in array declaration", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_STRING:
        if tokens[tok_ptr][T.TOKEN_VAL] != '{':
            raise SyntaxError("Missing '{' in array declaration", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        tok_ptr += 1

    tok = tokens[tok_ptr][T.TOKEN_TYPE]
    size = 0
    vals = []
    while tok in [T.TOKEN_NUMBER, T.TOKEN_FLOAT, T.TOKEN_STRING, T.TOKEN_IDENTIFIER, T.TOKEN_OPERATOR]:
        negate = False
        if tok == T.TOKEN_OPERATOR:
            if tokens[tok_ptr][T.TOKEN_VAL] != '-':
                raise SyntaxError("Invalid operator for an array element (only '-' is valid)", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
            negate = True
            tok_ptr += 1
            tok = tokens[tok_ptr][T.TOKEN_TYPE]

        if tok in [T.TOKEN_NUMBER, T.TOKEN_FLOAT]:
            val = int(tokens[tok_ptr][T.TOKEN_VAL])
            if negate:
                if arr_type == 'int':
                    val = (~val + 1) & 0xffff
                else:
                    val |= 0x8000
            val_node = N.Node(N.NODE_NUMBER)
            val_node.num = val
            val_node.type = arr_type
            val_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            vals.append(val_node)
        elif negate:
            raise SyntaxError("Can only negate numeric array elements", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        elif tok == T.TOKEN_STRING:
            string = tokens[tok_ptr][T.TOKEN_VAL]
            for char in string:
                val_node = N.Node(N.NODE_CHAR)
                val_node.char = ord(char)
                val_node.type = arr_type
                val_node.line = tokens[tok_ptr][T.TOKEN_LINE]
                vals.append(val_node)
                size += 1

            val_node = N.Node(N.NODE_CHAR)
            val_node.char = 0
            val_node.type = arr_type
            val_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            vals.append(val_node)
            size += 1
            break
        else:
            id_node = N.Node(N.NODE_IDENTIFIER)
            id_node.name = tokens[tok_ptr][T.TOKEN_VAL]
            id_node.ptr = False
            id_node.type = arr_type
            id_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            vals.append(id_node)

        tok_ptr += 1
        size += 1
        if tokens[tok_ptr][T.TOKEN_VAL] == '}':
            break
        elif tokens[tok_ptr][T.TOKEN_VAL] != ',':
            raise SyntaxError("Missing ',' in array declaration", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

        tok_ptr += 1
        tok = tokens[tok_ptr][T.TOKEN_TYPE]

    if arr_size is None:
        arr_size = N.Node(N.NODE_NUMBER)
        arr_size.num = size
        arr_size.type = 'int'
        arr_size.line = tokens[tok_ptr][T.TOKEN_LINE]
    elif arr_size.type is not int:
        # Let the generator code deal with 'identifier sizes'
        pass
    elif size > arr_size.num:
        raise SyntaxError('The initialisation data exceeds the array size', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
    else:
        while size < arr_size.num:
            val_node = N.Node(N.NODE_NUMBER)
            val_node.num = 0
            val_node.type = arr_type
            val_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            vals.append(val_node)
            size += 1

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != ';':
        raise SyntaxError('Unterminated array declaration', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    node.dim_node = arr_size
    node.arr_vals = vals
    node.type = arr_type
    node.line = tokens[tok_ptr][T.TOKEN_LINE]

    return (node, tok_ptr)

def parseExpression(tok_ptr):
    # Expr format:
    #   (unary_op)? term (op term)?

    # Expr node:
    #   NODE_EXPRESSION, unary_op, term, (op, term)?, line

    node = N.Node(N.NODE_EXPRESSION)

    if tokens[tok_ptr][T.TOKEN_VAL] in T.unary_ops:
        node.unary_op = tokens[tok_ptr][T.TOKEN_VAL]
        tok_ptr += 1

    tok_ptr = parseTerm(node, tok_ptr, left=True)
    while tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_OPERATOR:
        op = tokens[tok_ptr][T.TOKEN_VAL]
        node.op = op
        if op == '++' or op == '--':
            node_one = N.Node(N.NODE_NUMBER)
            node_one.num = 1
            node_one.type = 'int'
            node_one.line = tokens[tok_ptr][T.TOKEN_LINE]
            node.term_r = node_one
            tok_ptr += 1
        else:
            tok_ptr += 1
            tok_ptr = parseTerm(node, tok_ptr, left= False)

    node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return (node, tok_ptr)

def parseTerm(node, tok_ptr, left=False):
    # Term format
    #   num | char | ident | ('(' expr ')')

    # Term node:
    #   NODE_NUMBER | NODE_CHAR | NODE_IDENTIFIER | NODE_EXPRESSION

    if tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_NUMBER:
        val_node = N.Node(N.NODE_NUMBER)
        val_node.num = int(tokens[tok_ptr][T.TOKEN_VAL])
        val_node.type = 'int'
        val_node.line = tokens[tok_ptr][T.TOKEN_LINE]
        if left:
            node.term_l = val_node
        else:
            node.term_r = val_node
        tok_ptr += 1

    elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_FLOAT:
        val_node = N.Node(N.NODE_NUMBER)
        val_node.num = int(tokens[tok_ptr][T.TOKEN_VAL])
        val_node.type = 'float'
        val_node.line = tokens[tok_ptr][T.TOKEN_LINE]
        if left:
            node.term_l = val_node
        else:
            node.term_r = val_node
        tok_ptr += 1

    elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_CHAR:
        val_node = N.Node(N.NODE_CHAR)
        val_node.char = ord(tokens[tok_ptr][T.TOKEN_VAL])
        val_node.type = 'char'
        val_node.line = tokens[tok_ptr][T.TOKEN_LINE]
        if left:
            node.term_l = val_node
        else:
            node.term_r = val_node
        tok_ptr += 1

    elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
        if tokens[tok_ptr+1][T.TOKEN_VAL] == '[':
            ident_node = N.Node(N.NODE_IDENTIFIER)
            var_name = tokens[tok_ptr][T.TOKEN_VAL]
            ident_node.name = var_name
            ident_node.ptr = False

            tok_ptr += 2
            if tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_NUMBER:
                ident_node.index = int(tokens[tok_ptr][T.TOKEN_VAL])
            elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
                ident_node.index = tokens[tok_ptr][T.TOKEN_VAL]
            else:
                raise SyntaxError("Can only use int's or variables as array indices", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

            var_type = getVarType(var_name, tokens[tok_ptr][T.TOKEN_LINE])
            ident_node.type = var_type
            ident_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            if left:
                node.term_l = ident_node
            else:
                node.term_r = ident_node
            tok_ptr += 1
            if tokens[tok_ptr][T.TOKEN_VAL] != ']':
                raise SyntaxError("Missing ']' in array term", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        else:
            var_name = tokens[tok_ptr][T.TOKEN_VAL]
            var_type = getVarType(var_name, tokens[tok_ptr][T.TOKEN_LINE])
            ident_node = N.Node(N.NODE_IDENTIFIER)
            ident_node.name = var_name
            ident_node.ptr = False
            ident_node.type = var_type
            ident_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            if left:
                node.term_l = ident_node
            else:
                node.term_r = ident_node
        tok_ptr += 1

    elif tokens[tok_ptr][T.TOKEN_VAL] == '(':
        expr_node, tok_ptr = parseExpression(tok_ptr+1)
        if left:
            node.term_l = expr_node
        else:
            node.term_r = expr_node

        if tokens[tok_ptr][T.TOKEN_VAL] != ')':
            raise SyntaxError("Missing ')' after an expression", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        tok_ptr += 1

    else:
        raise SyntaxError("Invalid expression", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    return tok_ptr

def parseFunction(tok_ptr):
    # Fuction format:
    #   ('int' | 'float' | 'char' | 'void') name '(' (params)? ')' '{' body '}'
    #   where params = ('int' | 'float' | 'char) ('*')? name (',' ('int' | 'float' | 'char') ('*')? name)*

    # Function node:
    #   NODE_FUNCTION, name, ret_type, (NODE_PARAM)*, NODE_BODY, line
    global in_func, param_var_types, local_var_types
    global func_ret_types, func_ret_type, func_has_ret_val

    in_func = True
    param_var_types = {}
    local_var_types = {}
    func_has_ret_val = False

    node = N.Node(N.NODE_FUNCTION)

    # Return type
    ret_type = tokens[tok_ptr][T.TOKEN_VAL]
    func_ret_type = ret_type
    node.ret_type = ret_type

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_IDENTIFIER:
        raise SyntaxError("Invalid function identifier", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
    func_name = tokens[tok_ptr][T.TOKEN_VAL]
    node.name = func_name
    func_ret_types[func_name] = func_ret_type

    # Already dealt with '('
    tok_ptr += 2
    if tokens[tok_ptr][T.TOKEN_VAL] != ')':
        node_params, tok_ptr = parseParams(tok_ptr)
        node.param_vals = node_params
    elif tokens[tok_ptr][T.TOKEN_VAL] == ')':
        node.param_vals = []
    else:
        raise SyntaxError("Invalid function parameter list", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != '{':
        raise SyntaxError("Function missing '{'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    body_node, tok_ptr = parseBody(tok_ptr)
    node.body = body_node

    node.line = tokens[tok_ptr][T.TOKEN_LINE]

    if (func_has_ret_val and func_ret_type == 'void') or   \
       (not func_has_ret_val and func_ret_type != 'void'):
        raise SyntaxError('Invalid function return type', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    in_func = False
    return (node, tok_ptr)

def parseParams(tok_ptr):
    # Params format:
    #   ('int' | 'float' | 'char) ('*')? name (',' ('int' | 'float' | 'char') ('*')? name)*

    # Param node:
    #   NODE_PARAM, name, type, is_ptr, line

    param_type = tokens[tok_ptr][T.TOKEN_VAL]
    if param_type not in ['int', 'float', 'char']:
        raise SyntaxError("Invalid parameter type", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    ptr = False
    if tokens[tok_ptr+1][T.TOKEN_VAL] == '*':
        ptr = True
        tok_ptr += 1

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_IDENTIFIER:
        raise SyntaxError("Invalid parameter name", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    params = []
    param_name = tokens[tok_ptr][T.TOKEN_VAL]
    param_var_types[param_name] = param_type
    param_node = N.Node(N.NODE_PARAM)
    param_node.name = param_name
    param_node.ptr = ptr
    param_node.type = param_type
    param_node.line = tokens[tok_ptr][T.TOKEN_LINE]
    params.append(param_node)
    tok_ptr += 1

    while tokens[tok_ptr][T.TOKEN_VAL] == ',':
        tok_ptr += 1

        param_type = tokens[tok_ptr][T.TOKEN_VAL]
        if param_type not in ['int', 'float', 'char']:
            raise SyntaxError("Invalid parameter type", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

        ptr = False
        if tokens[tok_ptr+1][T.TOKEN_VAL] == '*':
            ptr = True
            tok_ptr += 1

        tok_ptr += 1
        if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_IDENTIFIER:
            raise SyntaxError("Invalid parameter name", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

        param_name = tokens[tok_ptr][T.TOKEN_VAL]
        param_var_types[param_name] = param_type
        param_node = N.Node(N.NODE_PARAM)
        param_node.name = param_name
        param_node.ptr = ptr
        param_node.type = param_type
        param_node.line = tokens[tok_ptr][T.TOKEN_LINE]
        params.append(param_node)
        tok_ptr += 1

    return params, tok_ptr

def parseBody(tok_ptr):
    # Body format:
    #   (var_init | var_update | statement)*
    
    # Body node:
    #   NODE_BODY, (NODE_VAR_INIT | NODE_VAR_UPDATE | NODE_STATEMENT)*, line

    body_node = N.Node(N.NODE_BODY)
    body_lines =[]
    while tokens[tok_ptr][T.TOKEN_VAL] != '}':
        if tokens[tok_ptr][T.TOKEN_VAL] in ['int', 'float', 'char']:
            if tokens[tok_ptr+2][T.TOKEN_VAL] == '[':
                node, tok_ptr = parseArrayInit(tok_ptr)
                body_lines.append(node)
            else:
                var_nodes, tok_ptr = parseVariableInit(tok_ptr)
                for node in var_nodes:
                    body_lines.append(node)
        elif tokens[tok_ptr][T.TOKEN_VAL] == '*':
            node, tok_ptr = parseVariableUpdate(tok_ptr)
            body_lines.append(node)
        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
            if tokens[tok_ptr+1][T.TOKEN_VAL] == '=':
                node, tok_ptr = parseVariableUpdate(tok_ptr)
            elif tokens[tok_ptr+1][T.TOKEN_VAL] == '[':
                node, tok_ptr = parseVariableUpdate(tok_ptr)
            elif tokens[tok_ptr+1][T.TOKEN_VAL] in T.double_ops:
                node, tok_ptr = parseExpression(tok_ptr)
            else:
                node, tok_ptr = parseFunctionCall(tok_ptr)
            body_lines.append(node)
        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_KEYWORD:
            node, tok_ptr = parseStatement(tok_ptr)
            body_lines.append(node)
        else:
            raise SyntaxError("Invalid statement", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

        if tok_ptr == (len(tokens) - 1):
            raise SyntaxError("Function/Body missing '}'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        tok_ptr += 1

    body_node.body_lines = body_lines
    body_node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return body_node, tok_ptr

def parseVariableUpdate(tok_ptr, for_update=False):
    # Var Update format:
    #   ('*')? name ('[' expr ']')? '=' (unary_op)? (expr | func_call) ';'

    # Var Update node:
    #  NODE_VAR_UPDATE, name, is_ptr, unary_op, (NODE_NUMBER | NODE_IDENTIFIER), (NODE_NUMBER | NODE_CHAR | NODE_IDENTIFIER | NODE_EXPRESSION | NODE_FUNC_CALL), line
    global in_func, local_var_types, global_var_types

    node = N.Node(N.NODE_VAR_UPDATE)

    # Is it a pointer update ?
    ptr = False
    if tokens[tok_ptr][T.TOKEN_VAL] == '*':
        ptr = True
        tok_ptr += 1

    var_name = tokens[tok_ptr][T.TOKEN_VAL]
    var_type = getVarType(var_name, tokens[tok_ptr][T.TOKEN_LINE])
    node.name = var_name

    # If the var is in an array get its index
    if tokens[tok_ptr+1][T.TOKEN_VAL] == '[':
        tok_ptr += 2
        if tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_NUMBER:
            index_node = N.Node(N.NODE_NUMBER)
            index_node.num = int(tokens[tok_ptr][T.TOKEN_VAL])
            index_node.type = 'int'
            index_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            node.index = index_node

        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
            index_name = tokens[tok_ptr][T.TOKEN_VAL]
            index_type = getVarType(index_name, tokens[tok_ptr][T.TOKEN_LINE])
            index_node = N.Node(N.NODE_IDENTIFIER)
            index_node.name = index_name
            index_node.ptr = False
            index_node.type = index_type
            index_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            node.index = index_node
        else:
            raise SyntaxError("Can only use int's or variables as array indices", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

        tok_ptr += 1
        if tokens[tok_ptr][T.TOKEN_VAL] != ']':
            raise SyntaxError("Missing ']' in an array update, or using an expression for the index, which isn't valid", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    node.ptr = ptr

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] == '=':
        tok_ptr += 1
        if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_CHAR and tokens[tok_ptr][T.TOKEN_VAL] in T.unary_ops:
            node.unary_op = tokens[tok_ptr][T.TOKEN_VAL]
            tok_ptr += 1

        if tokens[tok_ptr+1][T.TOKEN_VAL] == '(':
            func_node, tok_ptr = parseFunctionCall(tok_ptr, exp_type=var_type)
            node.val_node = func_node
        else:
            if tokens[tok_ptr+1][T.TOKEN_VAL] == ';':
                if tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_NUMBER:
                    if var_type != 'int':
                        raise SyntaxError('Type mismatch when updating a variable', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
                    var_node = N.Node(N.NODE_NUMBER)
                    var_node.num = int(tokens[tok_ptr][T.TOKEN_VAL])
                    var_node.type = 'int'
                    var_node.line = tokens[tok_ptr][T.TOKEN_LINE]
                    tok_ptr += 1
                elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_FLOAT:
                    if var_type != 'float':
                        raise SyntaxError('Type mismatch when updating a variable', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
                    var_node = N.Node(N.NODE_NUMBER)
                    var_node.num = int(tokens[tok_ptr][T.TOKEN_VAL])
                    var_node.type = 'float'
                    var_node.line = tokens[tok_ptr][T.TOKEN_LINE]
                    tok_ptr += 1
                elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_CHAR:
                    if var_type != 'char':
                        raise SyntaxError('Type mismatch when updating a variable', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
                    var_node = N.Node(N.NODE_CHAR)
                    var_node.char = ord(tokens[tok_ptr][T.TOKEN_VAL])
                    var_node.type = 'char'
                    var_node.line = tokens[tok_ptr][T.TOKEN_LINE]
                    tok_ptr += 1
                elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
                    var_name = tokens[tok_ptr][T.TOKEN_VAL]
                    id_var_type = getVarType(var_name, tokens[tok_ptr][T.TOKEN_LINE])
                    if id_var_type != var_type:
                        raise SyntaxError('Type mismatch when updating a variable', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
                    var_node = N.Node(N.NODE_IDENTIFIER)
                    var_node.name = var_name
                    var_node.ptr = False
                    var_node.type = var_type
                    var_node.line = tokens[tok_ptr][T.TOKEN_LINE]
                    tok_ptr += 1
                else:
                    raise SyntaxError('Unexpected token when updating a variable', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
            else:
                var_node, tok_ptr = parseExpression(tok_ptr)
            node.val_node = var_node
    else:
        raise SyntaxError("Expected '=' when updating a variable", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    if not for_update and tokens[tok_ptr][T.TOKEN_VAL] != ';':
        raise SyntaxError('Unterminated variable update detected', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
    
    node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return (node, tok_ptr)

def parseFunctionCall(tok_ptr, exp_type=None):
    # Func Call format:
    #   name '(' (num | char | ident)* ')'

    # Func Call node:
    #  NODE_FUNC_CALL, name, (NODE_NUMBER | NODE_CHAR | NODE_IDENTIFIER)*, line

    node = N.Node(N.NODE_FUNC_CALL)
    if tokens[tok_ptr][T.TOKEN_TYPE] != T.TOKEN_IDENTIFIER:
        raise SyntaxError('Invalid function call', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    func_name = tokens[tok_ptr][T.TOKEN_VAL]
    if func_name not in func_ret_types:
        raise SyntaxError('Calling an undefined function', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    node.name = func_name

    try:
        if exp_type is not None:
            ret_type = func_ret_types[func_name]
            if ret_type != 'any' and exp_type != ret_type:
                raise SyntaxError('Type mismatch when updating a variable', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
    except:
        raise SyntaxError(f"'{func_name}' is undefined, or has a mismatched return type", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 2
    params = []
    while tokens[tok_ptr][T.TOKEN_VAL] != ')':
        negate = False

        if tokens[tok_ptr][T.TOKEN_VAL] in ['*', '&']:
            raise SyntaxError("Invalid parameter list in function call (NB: '*' and '&' aren't allowed)", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

        if tokens[tok_ptr][T.TOKEN_VAL] == '-' and tokens[tok_ptr+1][T.TOKEN_TYPE] in [T.TOKEN_NUMBER, T.TOKEN_FLOAT]:
            negate = True
            tok_ptr += 1

        if tokens[tok_ptr][T.TOKEN_TYPE] in [T.TOKEN_NUMBER, T.TOKEN_FLOAT]:
            val = int(tokens[tok_ptr][T.TOKEN_VAL])
            var_type = 'int'
            if tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_FLOAT:
                var_type = 'float'
            if negate:
                if var_type == 'int':
                    val = (~val + 1) & 0xffff
                else:
                    val |= 0x8000
            num_node = N.Node(N.NODE_NUMBER)
            num_node.num = val
            num_node.type = var_type
            num_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            params.append(num_node)

        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_CHAR:
            char_node = N.Node(N.NODE_CHAR)
            char_node.char = ord(tokens[tok_ptr][T.TOKEN_VAL])
            char_node.type = 'char'
            char_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            params.append(char_node)

        elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
            id_name = tokens[tok_ptr][T.TOKEN_VAL]
            id_type = getVarType(id_name, tokens[tok_ptr][T.TOKEN_LINE])
            id_node = N.Node(N.NODE_IDENTIFIER)
            id_node.name = id_name
            id_node.ptr = False
            if tokens[tok_ptr+1][T.TOKEN_VAL] == '[':
                tok_ptr += 2
                if tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_NUMBER:
                    id_node.index = int(tokens[tok_ptr][T.TOKEN_VAL])
                elif tokens[tok_ptr][T.TOKEN_TYPE] == T.TOKEN_IDENTIFIER:
                    id_node.index = tokens[tok_ptr][T.TOKEN_VAL]
                else:
                    raise SyntaxError("Can only use numbers or variables as array indices", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
                tok_ptr += 1
                if tokens[tok_ptr][T.TOKEN_VAL] != ']':
                    raise SyntaxError("Missing ']' in array term", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
            id_node.type = id_type
            id_node.line = tokens[tok_ptr][T.TOKEN_LINE]
            params.append(id_node)

        else:
            raise SyntaxError("Invalid parameter list in function call (NB: Expressions aren't allowed)", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

        tok_ptr += 1
        if tokens[tok_ptr][T.TOKEN_VAL] not in [',', ')']:
            raise SyntaxError("Invalid parameter list in function call (NB: Expressions aren't allowed)", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        if tokens[tok_ptr][T.TOKEN_VAL] == ',':
            tok_ptr += 1

    node.param_vals = params
    
    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != ';':
        raise SyntaxError('Unterminated function call detected', (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return (node, tok_ptr)

def parseStatement(tok_ptr):
    # Statement format:
    #   return | while | for | if

    # Statement node:
    #  NODE_STATEMENT, (NODE_RETURN | NODE_WHILE | NODE_FOR | NODE_IF), line

    node = N.Node(N.NODE_STATEMENT)

    if tokens[tok_ptr][T.TOKEN_VAL] == 'return':
        ret_node, tok_ptr = parseReturn(node, tok_ptr)
        node.statement = ret_node

    elif tokens[tok_ptr][T.TOKEN_VAL] == 'while':
        while_node, tok_ptr = parseWhile(node, tok_ptr)
        node.statement = while_node

    elif tokens[tok_ptr][T.TOKEN_VAL] == 'for':
        for_node, tok_ptr = parseFor(node, tok_ptr)
        node.statement = for_node

    elif tokens[tok_ptr][T.TOKEN_VAL] == 'if':
        if_node, tok_ptr = parseIf(node, tok_ptr)
        node.statement = if_node

    elif tokens[tok_ptr][T.TOKEN_VAL] == 'break':
        break_node = N.Node(N.NODE_BREAK)
        node.statement = break_node
        tok_ptr += 1
        if tokens[tok_ptr][T.TOKEN_VAL] != ';':
            raise SyntaxError("Missing ';' after 'break'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    elif tokens[tok_ptr][T.TOKEN_VAL] == 'continue':
        cont_node = N.Node(N.NODE_CONTINUE)
        node.statement = cont_node
        tok_ptr += 1
        if tokens[tok_ptr][T.TOKEN_VAL] != ';':
            raise SyntaxError("Missing ';' after 'continue'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    else:
        raise SyntaxError("Invalid statement", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return(node, tok_ptr)

def parseReturn(node, tok_ptr):
    # Return format:
    #   'return' (expr)? ';'

    # Return node:
    #   NODE_RETURN, (NODE_EXPRESSION)?, line
    global func_has_ret_val

    node = N.Node(N.NODE_RETURN)

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != ';':
        func_has_ret_val = True
        if func_ret_type == 'void':
            raise SyntaxError("Invalid 'return' type", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
        elif tokens[tok_ptr][T.TOKEN_TYPE] in [T.TOKEN_IDENTIFIER, T.TOKEN_NUMBER, T.TOKEN_FLOAT, T.TOKEN_CHAR] or  \
             tokens[tok_ptr][T.TOKEN_VAL] == '(':
            expr_node, tok_ptr = parseExpression(tok_ptr)
            node.expr_node = expr_node
        else:
            raise SyntaxError("Invalid 'return' expression", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))
    elif func_ret_type != 'void':
            raise SyntaxError("Invalid 'return' type", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    if tokens[tok_ptr][T.TOKEN_VAL] != ';':
        raise SyntaxError("Unterminated 'return' detected", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return (node, tok_ptr)

def parseIf(node, tok_ptr):
    # If format:
    #   ‘if’ ‘(‘ expr ‘) ‘{‘ body ‘}’ (‘else’ ‘{‘ body ‘}’)?

    # If node:
    #   NODE_IF, NODE_EXPRESSION, NODE_BODY, (NODE_BODY)?, line
    node = N.Node(N.NODE_IF)

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != '(':
        raise SyntaxError("Expected '(' after 'if'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    expr_node, tok_ptr = parseExpression(tok_ptr)
    node.expr_node = expr_node

    if tokens[tok_ptr][T.TOKEN_VAL] != ')':
        raise SyntaxError("Expected ')' after 'if' expression", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != '{':
        raise SyntaxError("'if' missing '{'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    body_node, tok_ptr = parseBody(tok_ptr)
    node.body_if = body_node

    if tok_ptr < (len(tokens) - 1) and tokens[tok_ptr+1][T.TOKEN_VAL] == 'else':
        tok_ptr += 2
        if tokens[tok_ptr][T.TOKEN_VAL] != '{':
            raise SyntaxError("'else' missing '{'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

        tok_ptr += 1
        body_node, tok_ptr = parseBody(tok_ptr)
        node.body_else = body_node

    node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return (node, tok_ptr)

def parseWhile(node, tok_ptr):
    # While format:
    #   'while' '(' expr ')' '{' body '}'

    # While node:
    #   NODE_WHILE, NODE_EXPRESSION, NODE_BODY, line

    node = N.Node(N.NODE_WHILE)
    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != '(':
        raise SyntaxError("Expected '(' after 'while'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    expr_node, tok_ptr = parseExpression(tok_ptr)
    node.expr_node = expr_node

    if tokens[tok_ptr][T.TOKEN_VAL] != ')':
        raise SyntaxError("Expected ')' after 'while' expression", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != '{':
        raise SyntaxError("'while' missing '{'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    body_node, tok_ptr = parseBody(tok_ptr)
    node.body = body_node

    node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return (node, tok_ptr)

def parseFor(node, tok_ptr):
    # For format:
    #   'for' '(' (var_init  | var_update) ';' expr ';' var_update ')' '{' body '}'

    # For node:
    #   NODE_FOR, (NODE_VAR_INIT | NODE_VAR_UPDATE | NODE_EMPTY), (NODE_EXPRESSION | NODE_EMPTY), (NODE_VAR_UPDATE | NODE_EMPTY), NODE_BODY, line_num

    node = N.Node(N.NODE_FOR)

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != '(':
        raise SyntaxError("Expected '(' after 'for'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != ';':
        node_var, tok_ptr = parseVariableUpdate(tok_ptr, for_update=True)
        node.for_init = node_var
        if tokens[tok_ptr][T.TOKEN_VAL] != ';':
            raise SyntaxError("Expected ';' after 'for variable initialise'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != ';':
        expr_node, tok_ptr = parseExpression(tok_ptr)
        node.for_expr = expr_node
        if tokens[tok_ptr][T.TOKEN_VAL] != ';':
            raise SyntaxError("Expected ';' after 'for test'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != ')':
        node_var, tok_ptr = parseVariableUpdate(tok_ptr, for_update=True)
        node.for_update = node_var
        if tokens[tok_ptr][T.TOKEN_VAL] != ')':
            raise SyntaxError("Expected ')' after 'for variable update'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    if tokens[tok_ptr][T.TOKEN_VAL] != '{':
        raise SyntaxError("'for loop' missing '{'", (fileIn, tokens[tok_ptr][T.TOKEN_LINE], 0, ''))

    tok_ptr += 1
    body_node, tok_ptr = parseBody(tok_ptr)
    node.body = body_node

    node.line = tokens[tok_ptr][T.TOKEN_LINE]
    return (node, tok_ptr)

# Print all the nodes (for debugging ...)
def printNodes(nodes):
    print('\nGLOBAL NODES:')
    print('-------------')
    for node in nodes:
        if node.node_type in [N.NODE_VAR_INIT, N.NODE_ARRAY_INIT]:
            print(node)
            print()

    print('\nFUNCTION NODES:')
    print('---------------')
    for node in nodes:
        if node.node_type == N.NODE_FUNCTION:
            print(node)
            print()

    print()

