/*————————————————————————————————————————————————————————————————————————————
   Copyright (c) 2020–2021 Craig Ferguson <me@craigfe.io>
   Distributed under the MIT license. See terms at the end of this file.
  ————————————————————————————————————————————————————————————————————————————*/

#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <windows.h>

#define WIN32_LEAN_AND_MEAN
#define VC_EXTRALEAN

CAMLprim value ocaml_terminal_get_terminal_dimensions(value unit)
{
	CAMLparam1(unit);
	CAMLlocal2(result, pair);

	CONSOLE_SCREEN_BUFFER_INFO csbi;
	int success = GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
	if (success)
	{
		result = caml_alloc(1, 0);
		pair = caml_alloc(2, 0);
		Store_field(result, 0, pair);
		Store_field(pair, 0, Val_int((int)(csbi.dwSize.Y)));
		Store_field(pair, 1, Val_int((int)(csbi.dwSize.X)));
	}
	else
	{
		result = Val_int(0);
	}

	CAMLreturn(result);
}

/*————————————————————————————————————————————————————————————————————————————
   Copyright (c) 2020–2021 Craig Ferguson <me@craigfe.io>

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
   DEALINGS IN THE SOFTWARE.
  ————————————————————————————————————————————————————————————————————————————*/