# from pygments.style import Style
# from pygments.token import (
#     Token,
#     Keyword,
#     Name,
#     Comment,
#     String,
#     Error,
#     Number,
#     Operator,
#     Generic,
# )
# from IPython.terminal.prompts import Prompts


# class CustomStyle(Style):
#     styles = {Token.Text: ""}


# class CustomPrompts(Prompts):
#     def in_prompt_tokens(self, cli=None):
#         return [
#             (Token.Text, "❯\u00A0"),
#             (Token.PromptNum, "In ["),
#             (Token.PromptNum, str(self.shell.execution_count)),
#             (Token.Prompt, "]: "),
#         ]


# c.TerminalInteractiveShell.prompts_class = CustomPrompts
# c.TerminalInteractiveShell.highlighting_style = CustomStyle
