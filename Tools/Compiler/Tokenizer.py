
'''
Tokenizer

Create a list of tokens from the 'rmg' file.
Tokens are in the form: (type, val, line).

'''

import os
import math

keywords = ['int', 'float', 'char', 'void', 'if', 'else',
            'for', 'continue', 'break', 'while', 'return']

symbols = ['{', '}', '(', ')', '[', ']', ',', ';', "'", '"']

operators = ['+', '-', '*', '/', '%', '&', '|', '^', '<', '>', '=', '~', '!']

unary_ops = ['-', '~', '!', '&', '*']

double_ops = ['++', '+=', '--', '-=', '*=', '/=', '&=', '|=',
              '^=', '<<', '>>', '&&', '||', '==', '!=', '<=', '>=']

# Token types
TOKEN_KEYWORD     = 0
TOKEN_SYMBOL      = 1
TOKEN_OPERATOR    = 2
TOKEN_IDENTIFIER  = 3
TOKEN_NUMBER      = 4
TOKEN_FLOAT       = 5
TOKEN_CHAR        = 6
TOKEN_STRING      = 7

# Token tuple positions
TOKEN_TYPE = 0
TOKEN_VAL  = 1
TOKEN_LINE = 2

# NaN & Inf's
NAN     = str(int('0x7e00', 16))
POS_INF = str(int('0x7c00', 16))
NEG_INF = str(int('0xfc00', 16))

HEX_ALPHAS  = ['A', 'B', 'C', 'D', 'E', 'F']
FLOAT_CHARS = ['.', 'E', '-']

# Globals
in_comment = False
fileIn = None

# Create the token list
def tokenize(file_in):
    global in_comment, fileIn
    tokens = []
    lib_tokens = []
    fileIn = file_in
    include_files = []

    lineNo = 0
    in_comment = False

    with open(fileIn,'r') as rmg:
        for line in rmg:
            lineNo += 1

            # Get any 'include files'
            if line.startswith('#'):
                line = line[1:]
                if line.startswith('include'):
                    line = line.split(' ')
                    line = line[1][:-1]
                    if line.startswith('\"') and line.endswith('\"'):
                        include_files.append(line[1:-1])
                    else:
                        raise SyntaxError("Invalid 'pre-processor' command", (fileIn, lineNo, 0, ''))
                    continue
                else:
                    raise SyntaxError("Invalid 'pre-processor' command", (fileIn, lineNo, 0, ''))

            # Ignore comments
            line = line.split('//')
            line = line[0].strip()
            if line.startswith('//'):
                continue
            if line.startswith('/*'):
                if not line.endswith('*/'):
                    in_comment = True
                continue
            if in_comment:
                if line.endswith('*/'):
                    in_comment = False
                continue

            # Ignore blank lines
            if len(line) == 0:
                    continue

            # Add the tokens in the line to the token list
            line_tokens = getTokens(line, lineNo)
            for token in line_tokens:
                tokens.append(token)

    if in_comment:
        raise SyntaxError("Error: There is an unterminated '/*' comment", (fileIn, lineNo, 0, ''))

    # Validate any include files
    try:
        for file in include_files:
            file = os.path.normpath(file)
            with open(file,'r') as f:
                for line in f:
                    line = line.strip()
                    if len(line) == 0:
                        continue
                    if line.startswith('int')   or  \
                       line.startswith('float') or  \
                       line.startswith('char'):
                        # Get the tokens for any 'library constants'
                        line_tokens = getTokens(line)
                        for token in line_tokens:
                            lib_tokens.append(token)
                    elif line.startswith('.equ') or \
                         line.startswith(';')    or \
                         line.startswith('//'):
                        pass
                    else:
                        print(f"\nCompilation Failed - Invalid line in include file:\n{file}\n")
                        exit(1)
        # Add any 'library tokens' to the start of the tokens list
        tokens = lib_tokens + tokens

    except FileNotFoundError:
        print(f"\nCompilation Failed - Couldn't open include file:\n{file}\n")
        exit(1)

    return tokens, include_files

# Return the tokens in a line
def getTokens(line, lineNo=-1):
    global in_comment
    tokens = []
    i = 0

    while i < len(line):

        if in_comment:
            # Check for the end of an inline comment
            if line[i:i+2] == '*/':
                in_comment = False
                i += 2
            else:
                i += 1
                continue

        if line[i] == ' ':
            i += 1
            continue

        elif line[i] in symbols:
            if line[i] == "'":
                token_type = TOKEN_CHAR
                val, chars = getChar(line[i:])
                if val is None:
                    raise SyntaxError('Unterminated char or Invalid escape char', (fileIn, lineNo, 0, ''))
                i += chars
            elif line[i] == '"':
                token_type = TOKEN_STRING
                val, esc_chrs = getStr(line[i:])
                if val is None:
                    raise SyntaxError('Unterminated string or Invalid escape char', (fileIn, lineNo, 0, ''))
                i += (len(val) + 2 + esc_chrs)
            else:
                token_type = TOKEN_SYMBOL
                val = getSymbol(line[i:])

        elif line[i] in operators:
            token_type = TOKEN_OPERATOR
            val = getOperator(line[i:])

            # Check for the start of an inline comment
            if val == '/*':
                in_comment = True
                i += 2
                continue

            if len(val) > 1 and val not in double_ops:
                raise SyntaxError(f'Invalid operator: {val}', (fileIn, lineNo, 0, ''))

        elif line[i].isnumeric():
            val, token_type, str_len = getNumber(line[i:])
            if val is None:
                raise SyntaxError(f'Invalid number format', (fileIn, lineNo, 0, ''))

            i += str_len

        elif validKeywordIdentChar(line[i]):
            val = getKeywordIdentifier(line[i:])
            if val in keywords:
                token_type = TOKEN_KEYWORD
            else:
                token_type = TOKEN_IDENTIFIER

        else:
            line = line[i:].split(' ')
            raise SyntaxError(f'{line[0]} is invalid', (fileIn, lineNo, 0, ''))

        if not in_comment:
            if token_type == TOKEN_SYMBOL:
                if len(val) > 1:
                    # Split multiple symbols into single symbols
                    for j in range(len(val)):
                        tokens.append((token_type, val[j], lineNo))
                else:
                    tokens.append((token_type, val, lineNo))
            else:
                tokens.append((token_type, val, lineNo))

        if token_type not in [TOKEN_NUMBER, TOKEN_FLOAT, TOKEN_CHAR, TOKEN_STRING]:
            i += len(val)

    return tokens

# Get a symbol
def getSymbol(line):
    val = ''
    for i in range(len(line)):
        if line[i] not in symbols:
            return val
        val += line[i]
    return val

# Get a char
def getChar(line):
    pos = 1
    chars = 3
    val = line[pos]

    # Deal with escape chars
    if val == '\\':
        pos += 1
        chars += 1
        char = line[pos]
        if char == 'n':
            val = chr(0x0a)
        elif char == '0':
            val = chr(0x00)
        elif char == '"':
            val = '"'
        elif char == '\\':
            val = '\\'
        else:
            # Invalid escape char
            val = None
            
    pos += 1
    if line[pos] != "'":
        val = None

    return (val, chars)

# Get a string
def getStr(line):
    string = ''
    pos = 1
    esc_chrs = 0

    while pos < len(line):
        if line[pos] != '"':
            char = line[pos]

            # Deal with escape chars
            if char == '\\':
                pos += 1
                esc_chrs += 1
                char = line[pos]
                if char == 'n':
                    char = chr(0x0a)
                elif char == '0':
                    char = chr(0x00)
                elif char == '"':
                    char = '"'
                elif char == '\\':
                    char = '\\'
                else:
                    # Invalid escape char
                    return None

            string += char
            pos += 1
        else:
            return (string, esc_chrs) 
               
    return None

# Get an operator
def getOperator(line):
    val = ''
    for i in range(len(line)):
        if line[i] not in operators:
            return val
        val += line[i]
    return val

# Get a number
def getNumber(line):
    val = ''
    j = 0
    is_float = is_bin = is_hex = False
    token_type = TOKEN_NUMBER

    line = line.upper()
    if line[0:2] == '0B':
        is_bin = True
        j = 2
    elif line[0:2] == '0X':
        is_hex = True
        j = 2

    for i in range(j, len(line)):
        if line[i] == '.':
            is_float = True
            token_type = TOKEN_FLOAT
        elif not line[i].isnumeric():
            if is_float:
                if line[i] not in FLOAT_CHARS:
                    break
                elif line[i] == '-':
                    if val[-1] != 'E':
                        break
                    elif not line[i+1].isnumeric():
                        break
                elif line[i] == '.':
                    return (None, 0)
            elif is_hex:
                if not line[i].isalnum():
                    break
            else:
                break
        val += line[i]

    # To fix case where the tokeniser isn't advancing if the last char in a line is a number
    if i == (len(line) - 1) and line[-1].isnumeric():
        i += 1

    if is_bin:
        for k in range(len(val)):
            if val[k] not in ['0', '1']:
                return (None, 0)
        val = str(int(val, 2))
    elif is_hex:
        for k in range(len(val)):
            if not val[k].isnumeric() and val[k].upper() not in HEX_ALPHAS:
                return (None, 0)
        val = str(int(val, 16))
    elif '.' in val or 'E' in val:
        # It's a float
        if not validFloat(val):
            return (None, 0)
        val = getFloat(val)

    return (val, token_type, i)

# Check for a string being a float
def validFloat(num):
    if num.count('E') > 1 or num.count('.') > 1:
        return False

    elif not num[-1].isnumeric():
        return False

    elif '.E' in num:
        return False
    
    return True

# Convert a decimal string to a hex floating point number
def getFloat(val):
    try:
        # Get the value
        val = float(val)

        if math.isnan(val) or val == float('inf') or val == float('-inf'):
            raise Exception()         

        # Get the sign bit
        if val < 0:
            val = abs(val)
            sign = '1'
        else:
            sign = '0'
         
        # Get the exponent
        exp = 15
         
        # If the number's 2 or above keep dividing by 2 until it's not.
        # While doing this the exponent must be incremented for each division,
        # so that val * (2**exp) remains equal to the initial number.
        while val >= 2:
            val /= 2
            exp += 1

        # Numbers beyond the normal range are infinite
        if exp > 30:
            if sign == '0':
                return POS_INF
            else:
                return NEG_INF

        # If the number's below 1 keep multiplying by 2 until it's not.
        # While doing this the exponent must be decremented for each multiplication,
        # so that val * (2**exp) remains equal to the initial number.
        while val < 1:
            val *= 2
            exp -= 1
            if exp == 0:
                # It's a subnormal number - exponent can't be lowered further
                val /= 2
                break

        # Get the mantissa
        mant = ''
         
        # Get rid of the leading '1' for normal numbers
        if exp != 0:
            val -= 1
               
        for _ in range(21):
            val = 2 * val
            if val >= 1:
                val -= 1
                mant += '1'
            else:
                mant += '0'

        # Perform rounding if necessary
        if (mant[9] == '0' and mant[10] == '1' and '1' in mant[11:]) or \
           (mant[9] == '1' and mant[10] == '1'):
            mant = mant[:10]
            mantInt = int(mant, 2) + 1
            if hex(mantInt) == '0x400':
                mant = '0' * 10
                exp += 1
            else:
                mant = f'{mantInt:010b}'
        else:
            mant = mant[:10]
      
        bin_str = sign + f'{exp:05b}' + mant
        return str(int(bin_str, 2))
      
    except:
        # The value is infinite or invalid
        if val == float('inf'):
            return POS_INF
        elif val == float('-inf'):
            return NEG_INF
        else:
            return NAN

# Get a keyword or an identifier
def getKeywordIdentifier(line):
    val = ''
    for i in range(len(line)):
        if validKeywordIdentChar(line[i]):
            val += line[i]
        else:
            return val
    return val

# Check to see if a keyword or identifier
# is valid by inspecting its 1st char
def validKeywordIdentChar(char):
    if char == '_' or                    \
       (char >= 'a' and char <= 'z') or  \
       (char >= 'A' and char <= 'Z') or  \
       (char >= '0' and char <= '9'):
        return True
    else:
        return False

# Print all the tokens (for debugging ...)
def printTokens(tokens):
    print('\nTOKENS:')
    print('-------\n')

    for token in tokens:
        type, val, line = token
        if line == -1:
            line = 'Library Token'

        if type == TOKEN_KEYWORD:
            str_type = 'KEYWORD'
        elif type == TOKEN_SYMBOL:
            str_type = 'SYMBOL'
        elif type == TOKEN_OPERATOR:
            str_type = 'OPERATOR'
        elif type == TOKEN_IDENTIFIER:
            str_type = 'IDENTIFIER'
        elif type == TOKEN_NUMBER:
            str_type = 'NUMBER'
        elif type == TOKEN_FLOAT:
            str_type = 'FLOAT'
        elif type == TOKEN_CHAR:
            str_type = 'CHAR'
        elif type == TOKEN_STRING:
            str_type = 'STRING'
        else:
            raise Exception('Invalid Token')

        if val == '\n' or val == '\0':
            val = hex(ord(val))

        print(f'Type: {str_type:12} Value: {val:15} Line: {line}')

    print()

