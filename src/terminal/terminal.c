#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <process.h>
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