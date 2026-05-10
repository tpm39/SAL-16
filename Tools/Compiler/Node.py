
'''
Node

The 'Node List' is comprised of instances of the Node class

'''

# Node types
NODE_NUMBER      = 0
NODE_CHAR        = 1
NODE_IDENTIFIER  = 2
NODE_VAR_INIT    = 3
NODE_ARRAY_INIT  = 4
NODE_VAR_UPDATE  = 5
NODE_EXPRESSION  = 6
NODE_FUNCTION    = 7
NODE_PARAM       = 8
NODE_BODY        = 9
NODE_FUNC_CALL   = 10
NODE_PARAM_VALS  = 11
NODE_STATEMENT   = 12
NODE_IF          = 13
NODE_WHILE       = 14
NODE_FOR         = 15
NODE_BREAK       = 16
NODE_CONTINUE    = 17
NODE_RETURN      = 18

class Node:
   TAB = 3 * ' '
   tab_cnt = -1
   indent = ''

   def __init__(self, node_type):
      self.node_type = node_type
      self.num = None
      self.char = None
      self.val_node = None
      self.arr_vals = None
      self.type = None
      self.name = None
      self.ptr = None
      self.dim_node = None
      self.index = None
      self.unary_op = None
      self.term_l = None
      self.term_r = None
      self.op = None
      self.ret_type = None
      self.param_vals = None
      self.body = None
      self.body_lines = None
      self.statement = None
      self.expr_node = None
      self.body_if = None
      self.body_else = None
      self.for_init = None
      self.for_expr = None
      self.for_update = None
      self.line = None

   def __str__(self):
      Node.inc_tab()
      desc = ''

      if self.node_type == NODE_NUMBER:
         desc += f'\n{Node.indent}NODE_NUMBER'

      elif self.node_type == NODE_CHAR:
         desc += f'\n{Node.indent}NODE_CHAR'

      elif self.node_type == NODE_IDENTIFIER:
         desc += f'\n{Node.indent}NODE_IDENTIFIER'

      elif self.node_type == NODE_VAR_INIT:
         desc += f'\n{Node.indent}NODE_VAR_INIT'

      elif self.node_type == NODE_ARRAY_INIT:
         desc += f'\n{Node.indent}NODE_ARRAY_INIT'

      elif self.node_type == NODE_VAR_UPDATE:
         desc += f'\n{Node.indent}NODE_VAR_UPDATE'

      elif self.node_type == NODE_EXPRESSION:
         desc += f'\n{Node.indent}NODE_EXPRESSION'

      elif self.node_type == NODE_FUNCTION:
         desc += f'\n{Node.indent}NODE_FUNCTION'

      elif self.node_type == NODE_PARAM:
         desc += f'\n{Node.indent}NODE_PARAM'

      elif self.node_type == NODE_BODY:
         desc += f'\n{Node.indent}NODE_BODY'

      elif self.node_type == NODE_FUNC_CALL:
         desc += f'\n{Node.indent}NODE_FUNC_CALL'

      elif self.node_type == NODE_PARAM_VALS:
         desc += f'\n{Node.indent}NODE_PARAM_VALS'

      elif self.node_type == NODE_STATEMENT:
         desc += f'\n{Node.indent}NODE_STATEMENT'

      elif self.node_type == NODE_IF:
         desc += f'\n{Node.indent}NODE_IF'

      elif self.node_type == NODE_WHILE:
         desc += f'\n{Node.indent}NODE_WHILE'

      elif self.node_type == NODE_FOR:
         desc += f'\n{Node.indent}NODE_FOR'

      elif self.node_type == NODE_BREAK:
         desc += f'\n{Node.indent}NODE_BREAK'

      elif self.node_type == NODE_CONTINUE:
         desc += f'\n{Node.indent}NODE_CONTINUE'
         
      elif self.node_type == NODE_RETURN:
         desc += f'\n{Node.indent}NODE_RETURN'

      Node.inc_tab()

      if self.name is not None:
         desc += f'\n{Node.indent}name = {self.name}'

      if self.num is not None:
         desc += f'\n{Node.indent}num = {self.num}'

      if self.char is not None:
         desc += f'\n{Node.indent}char = {self.char}'

      if self.val_node is not None:
         desc += f'\n{Node.indent}val_node = {self.val_node}'

      if self.type is not None:
         desc += f'\n{Node.indent}type = {self.type}'

      if self.ptr is not None:
         desc += f'\n{Node.indent}ptr = {self.ptr}'

      if self.index is not None:
         desc += f'\n{Node.indent}index = {self.index}'

      if self.unary_op is not None:
         desc += f'\n{Node.indent}unary_op = {self.unary_op}'

      if self.dim_node is not None:
         desc += f'\n{Node.indent}dim_node = {self.dim_node}'

      if self.arr_vals is not None:
         if len(self.arr_vals) == 0:
            desc += f'\n{Node.indent}arr_vals = []'
         else:
            for idx, val in enumerate(self.arr_vals):
               desc += f'\n{Node.indent}arr_vals[{idx}] = {val}'

      if self.term_l is not None:
         desc += f'\n{Node.indent}term_l = {self.term_l}'

      if self.op is not None:
         desc += f'\n{Node.indent}op = {self.op}'

      if self.term_r is not None:
         desc += f'\n{Node.indent}term_r = {self.term_r}'

      if self.ret_type is not None:
         desc += f'\n{Node.indent}ret_type = {self.ret_type}'

      if self.param_vals is not None:
         if len(self.param_vals) == 0:
            desc += f'\n{Node.indent}arr_vals = []'
         else:
            for idx, param in enumerate(self.param_vals):
               desc += f'\n{Node.indent}param_vals[{idx}] = {param}'

      if self.body is not None:
         desc += f'\n{Node.indent}body = {self.body}'

      if self.body_lines is not None:
         if len(self.body_lines) == 0:
            desc += f'\n{Node.indent}body_lines = []'
         else:
            for idx, line in enumerate(self.body_lines):
               desc += f'\n{Node.indent}body_lines[{idx}] = {line}'

      if self.statement is not None:
         desc += f'\n{Node.indent}statement = {self.statement}'

      if self.expr_node is not None:
         desc += f'\n{Node.indent}expr_node = {self.expr_node}'

      if self.body_if is not None:
         desc += f'\n{Node.indent}body_if = {self.body_if}'

      if self.body_else is not None:
         desc += f'\n{Node.indent}body_else = {self.body_else}'

      if self.for_init is not None:
         desc += f'\n{Node.indent}for_init = {self.for_init}'

      if self.for_expr is not None:
         desc += f'\n{Node.indent}for_expr = {self.for_expr}'

      if self.for_update is not None:
         desc += f'\n{Node.indent}for_update = {self.for_update}'

      if self.line is not None:
         if self.line == -1:
            self.line = 'Library Node'
         desc += f'\n{Node.indent}line = {self.line}'
         Node.dec_tab()
         Node.dec_tab()

      return desc

   def inc_tab():
      Node.tab_cnt += 1
      Node.indent = Node.tab_cnt * Node.TAB

   def dec_tab():
      Node.tab_cnt -= 1
      Node.indent = Node.tab_cnt * Node.TAB

